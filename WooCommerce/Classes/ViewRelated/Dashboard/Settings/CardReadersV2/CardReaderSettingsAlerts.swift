import UIKit
import Yosemite
import WordPressUI

/// A layer of indirection between our card reader settings view controllers and the modal alerts
/// presented to provide user-facing feedback as we discover, connect and manage card readers
///
final class CardReaderSettingsAlerts: CardReaderSettingsAlertsProvider {
    private var modalController: CardPresentPaymentsModalViewController?
    private var severalFoundController: SeveralReadersFoundViewController?

    func scanningForReader(from: UIViewController, cancel: @escaping () -> Void) {
        setViewModelAndPresent(from: from, viewModel: scanningForReader(cancel: cancel))
    }

    func scanningFailed(from: UIViewController, error: Error, close: @escaping () -> Void) {
        setViewModelAndPresent(from: from, viewModel: scanningFailed(error: error, close: close))
    }

    func connectingToReader(from: UIViewController) {
        setViewModelAndPresent(from: from, viewModel: connectingToReader())
    }

    func foundReader(from: UIViewController,
                     name: String,
                     connect: @escaping () -> Void,
                     continueSearch: @escaping () -> Void) {
        setViewModelAndPresent(from: from,
                               viewModel: foundReader(name: name,
                                                      connect: connect,
                                                      continueSearch: continueSearch
                               )
        )
    }

    /// Note: `foundSeveralReaders` uses a view controller distinct from the common
    /// `CardPresentPaymentsModalViewController` to avoid further
    /// overloading `CardPresentPaymentsModalViewModel`
    ///
    /// This will dismiss any view controllers using the common view model first before
    /// presenting the several readers found modal
    ///
    func foundSeveralReaders(from: UIViewController,
                             readerIDs: [String],
                             connect: @escaping (String) -> Void,
                             cancelSearch: @escaping () -> Void) {
        dismissCommon(animated: false)

        severalFoundController = SeveralReadersFoundViewController()
        severalFoundController?.configureController(
            readerIDs: readerIDs,
            connect: connect,
            cancelSearch: cancelSearch
        )

        guard let severalFoundController = severalFoundController else {
            return
        }

        from.present(severalFoundController, animated: false)
    }

    /// Used to update the readers list in the several readers found view
    ///
    func updateSeveralReadersList(readerIDs: [String]) {
        severalFoundController?.updateReaderIDs(readerIDs: readerIDs)
    }

    func dismiss() {
        dismissCommon(animated: true)
        dismissSeveralFound(animated: true)
    }
}

private extension CardReaderSettingsAlerts {
    /// Dismisses any view controller based on `CardPresentPaymentsModalViewController`
    ///
    func dismissCommon(animated: Bool = true) {
        modalController?.dismiss(animated: animated, completion: { [weak self] in
            self?.modalController = nil
        })
    }

    /// Dismisses the `SeveralReadersFoundViewController`
    ///
    func dismissSeveralFound(animated: Bool = true) {
        severalFoundController?.dismiss(animated: animated, completion: { [weak self] in
            self?.severalFoundController = nil
        })
    }

    func scanningForReader(cancel: @escaping () -> Void) -> CardPresentPaymentsModalViewModel {
        CardPresentModalScanningForReader(cancel: cancel)
    }

    func scanningFailed(error: Error, close: @escaping () -> Void) -> CardPresentPaymentsModalViewModel {
        switch error {
        case CardReaderServiceError.bluetoothDenied:
            return CardPresentModalBluetoothRequired(error: error, primaryAction: close)
        default:
            return CardPresentModalScanningFailed(error: error, primaryAction: close)
        }
    }

    func connectingToReader() -> CardPresentPaymentsModalViewModel {
        CardPresentModalConnectingToReader()
    }

    func foundReader(name: String, connect: @escaping () -> Void, continueSearch: @escaping () -> Void) -> CardPresentPaymentsModalViewModel {
        CardPresentModalFoundReader(name: name, connect: connect, continueSearch: continueSearch)
    }

    func setViewModelAndPresent(from: UIViewController, viewModel: CardPresentPaymentsModalViewModel) {
        dismissSeveralFound(animated: false)

        guard modalController == nil else {
            modalController?.setViewModel(viewModel)
            return
        }

        modalController = CardPresentPaymentsModalViewController(viewModel: viewModel)
        guard let modalController = modalController else {
            return
        }

        modalController.modalPresentationStyle = .custom
        modalController.transitioningDelegate = AppDelegate.shared.tabBarController
        from.present(modalController, animated: true)
    }
}
