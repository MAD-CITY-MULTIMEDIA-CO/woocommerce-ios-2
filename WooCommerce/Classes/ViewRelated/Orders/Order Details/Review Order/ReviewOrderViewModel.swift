import Foundation
import Yosemite
import protocol Storage.StorageManagerType

final class ReviewOrderViewModel {
    /// The order for review
    ///
    private let order: Order

    /// Products in the order
    ///
    private let products: [Product]

    /// StorageManager to load details of order from storage
    ///
    private let storageManager: StorageManagerType

    /// Reference to the StoresManager to dispatch Yosemite Actions.
    ///
    private let stores: StoresManager

    init(order: Order,
         products: [Product],
         stores: StoresManager = ServiceLocator.stores,
         storageManager: StorageManagerType = ServiceLocator.storageManager) {
        self.order = order
        self.products = products
        self.stores = stores
        self.storageManager = storageManager
    }
}

// MARK: - Data source for review order controller
//
extension ReviewOrderViewModel {
    var screenTitle: String {
        Localization.screenTitle
    }
}

// MARK: - Localization
//
private extension ReviewOrderViewModel {
    enum Localization {
        static let screenTitle = NSLocalizedString("Review Order", comment: "Title of Review Order screen")
    }
}