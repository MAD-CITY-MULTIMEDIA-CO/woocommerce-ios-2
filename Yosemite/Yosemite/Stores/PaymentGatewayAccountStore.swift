import Foundation
import Networking
import Storage

/// Implements `PaymentGatewayAccountAction` actions
///
public final class PaymentGatewayAccountStore: Store {

    /// For now, we only have one remote we support - the WCPay remote - to get an account
    /// In the future we'll want to allow this store to support other remotes
    ///
    private let remote: WCPayRemote

    public override init(dispatcher: Dispatcher, storageManager: StorageManagerType, network: Network) {
        self.remote = WCPayRemote(network: network)
        super.init(dispatcher: dispatcher, storageManager: storageManager, network: network)
    }

    /// Registers for supported Actions.
    ///
    override public func registerSupportedActions(in dispatcher: Dispatcher) {
        dispatcher.register(processor: self, for: PaymentGatewayAction.self)
    }

    /// Receives and executes Actions.
    ///
    override public func onAction(_ action: Action) {
        guard let action = action as? PaymentGatewayAccountAction else {
            assertionFailure("PaymentGatewayAccountAction received an unsupported action")
            return
        }

        switch action {
        case .loadAccounts(let siteID, let onCompletion):
            loadAccounts(siteID: siteID,
                         onCompletion: onCompletion)
        case .captureOrderPayment(let siteID,
                                  let orderID,
                                  let paymentIntentID,
                                  let onCompletion):
            captureOrderPayment(siteID: siteID,
                                orderID: orderID,
                                paymentIntentID: paymentIntentID,
                                onCompletion: onCompletion)
        }
    }
}

// MARK: Networking Methods
private extension PaymentGatewayAccountStore {
    func loadAccounts(siteID: Int64, onCompletion: @escaping (Result<Void, Error>) -> Void) {
        /// The only plugin we support payment gateway accounts for right now is WooCommerce Payments.
        /// And there is only one account per site for that plugin.  In the future we will need to support remotes for
        /// other plugins and it might be possible for there to be multiple accounts for a single site then.
        ///
        remote.loadAccount(for: siteID) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .success(let wcpayAccount):
                let account = wcpayAccount.toPaymentGatewayAccount(siteID: siteID)
                self.upsertStoredAccountInBackground(readonlyAccount: account)
                onCompletion(.success(()))
                    return
            case .failure(let error):
                self.deleteStaleAccount(siteID: siteID, gatewayID: WCPayAccount.gatewayID)
                onCompletion(.failure(error))
                return
            }
        }
    }

    func captureOrderPayment(siteID: Int64,
                             orderID: Int64,
                             paymentIntentID: String,
                             onCompletion: @escaping (Result<Void, Error>) -> Void) {
        /// The only plugin we support capturing payments with right now is WooCommerce Payments.
        /// In the future we will need to support remotes for other plugins.
        ///
        remote.captureOrderPayment(for: siteID, orderID: orderID, paymentIntentID: paymentIntentID, completion: { result in
            switch result {
            case .success(let intent):
                guard intent.status == .succeeded else {
                    DDLogDebug("Unexpected payment intent status \(intent.status) after attempting capture")
                    onCompletion(.failure(CardReaderServiceError.paymentCapture()))
                    return
                }

                onCompletion(.success(()))
            case .failure(let error):
                onCompletion(.failure(error))
                return
            }
        })
    }
}

// MARK: Storage Methods
private extension PaymentGatewayAccountStore {
    func upsertStoredAccountInBackground(readonlyAccount: PaymentGatewayAccount) {
        let storage = storageManager.viewStorage
        let storageAccount = storage.loadPaymentGatewayAccount(siteID: readonlyAccount.siteID, gatewayID: readonlyAccount.gatewayID) ??
            storage.insertNewObject(ofType: Storage.PaymentGatewayAccount.self)

        storageAccount.update(with: readonlyAccount)
    }

    func deleteStaleAccount(siteID: Int64, gatewayID: String) {
        let storage = storageManager.viewStorage
        guard let storageAccount = storage.loadPaymentGatewayAccount(siteID: siteID, gatewayID: gatewayID) else {
            return
        }

        storage.deleteObject(storageAccount)
        storage.saveIfNeeded()
    }
}