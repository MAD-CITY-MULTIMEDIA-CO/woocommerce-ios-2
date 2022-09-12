import WidgetKit
import WooFoundation
import KeychainAccess

/// Type that represents the all the possible Widget states.
///
enum StoreInfoEntry: TimelineEntry {
    // Represents a not logged-in state
    case notConnected

    // Represents a fetching error state
    case error

    // Represents a fetched data state
    case data(StoreInfoData)

    // Current date, needed by the `TimelineEntry` protocol.
    var date: Date { Date() }
}

/// Type that represents the the widget state data.
///
struct StoreInfoData {
    /// Eg: Today, Weekly, Monthly, Yearly
    ///
    var range: String

    /// Store name
    ///
    var name: String

    /// Revenue at the range (eg: today)
    ///
    var revenue: String

    /// Visitors count at the range (eg: today)
    ///
    var visitors: String

    /// Order count at the range (eg: today)
    ///
    var orders: String

    /// Conversion at the range (eg: today)
    ///
    var conversion: String
}

/// Type that provides data entries to the widget system.
///
final class StoreInfoProvider: TimelineProvider {

    /// Holds a reference to the service while a network request is being performed.
    ///
    private var networkService: StoreInfoDataService?

    /// Desired data reload interval provided to system = 30 minutes.
    ///
    private let reloadInterval: TimeInterval = 30 * 60

    /// Redacted entry with sample data.
    ///
    func placeholder(in context: Context) -> StoreInfoEntry {
        let dependencies = Self.fetchDependencies()
        return StoreInfoEntry.data(.init(range: Localization.today,
                                         name: dependencies?.storeName ?? Localization.myShop,
                                         revenue: "$132.234",
                                         visitors: "67",
                                         orders: "23",
                                         conversion: "34%"))
    }

    /// Quick Snapshot. Required when previewing the widget.
    ///
    func getSnapshot(in context: Context, completion: @escaping (StoreInfoEntry) -> Void) {
        completion(placeholder(in: context))
    }

    /// Real data widget.
    ///
    func getTimeline(in context: Context, completion: @escaping (Timeline<StoreInfoEntry>) -> Void) {
        guard let dependencies = Self.fetchDependencies() else {
            return completion(Timeline<StoreInfoEntry>(entries: [StoreInfoEntry.notConnected], policy: .never))
        }

        let strongService = StoreInfoDataService(authToken: dependencies.authToken, siteTimeZone: dependencies.storeTimeZone)
        networkService = strongService
        Task {
            do {
                let todayStats = try await strongService.fetchTodayStats(for: dependencies.storeID)

                let entry = StoreInfoEntry.data(.init(range: Localization.today,
                                                      name: dependencies.storeName,
                                                      revenue: formattedAmountString(for: todayStats.revenue, with: dependencies.storeCurrencySettings),
                                                      visitors: "\(todayStats.totalVisitors)",
                                                      orders: "\(todayStats.totalOrders)",
                                                      conversion: formattedConversionString(for: todayStats.conversion)))

                let reloadDate = Date(timeIntervalSinceNow: reloadInterval)
                let timeline = Timeline<StoreInfoEntry>(entries: [entry], policy: .after(reloadDate))
                completion(timeline)

            } catch {

                // WooFoundation does not expose `DDLOG` types. Should we include them?
                print("⛔️ Error fetching today's widget stats: \(error)")

                let reloadDate = Date(timeIntervalSinceNow: reloadInterval)
                let timeline = Timeline<StoreInfoEntry>(entries: [.error], policy: .after(reloadDate))
                completion(timeline)
            }
        }
    }
}

private extension StoreInfoProvider {

    /// Dependencies needed by the `StoreInfoProvider`
    ///
    struct Dependencies {
        let authToken: String
        let storeID: Int64
        let storeName: String
        let storeTimeZone: TimeZone
        let storeCurrencySettings: CurrencySettings
    }

    /// Fetches the required dependencies from the keychain and the shared users default.
    ///
    static func fetchDependencies() -> Dependencies? {
        let keychain = Keychain(service: WooConstants.keychainServiceName)
        guard let authToken = keychain[WooConstants.authToken],
              let storeID = UserDefaults.group?[.defaultStoreID] as? Int64,
              let storeName = UserDefaults.group?[.defaultStoreName] as? String,
              let storeTimeZoneGMTOffset = UserDefaults.group?[.defaultStoreTimeZoneGMTOffset] as? Int,
              let storeTimeZone = TimeZone(secondsFromGMT: storeTimeZoneGMTOffset),
              let storeCurrencySettingsData = UserDefaults.group?[.defaultStoreCurrencySettings] as? Data,
              let storeCurrencySettings = try? JSONDecoder().decode(CurrencySettings.self, from: storeCurrencySettingsData) else {
            return nil
        }
        return Dependencies(authToken: authToken,
                            storeID: storeID,
                            storeName: storeName,
                            storeTimeZone: storeTimeZone,
                            storeCurrencySettings: storeCurrencySettings)
    }
}

private extension StoreInfoProvider {

    func formattedAmountString(for amountValue: Decimal, with currencySettings: CurrencySettings?) -> String {
        let currencyFormatter = CurrencyFormatter(currencySettings: currencySettings ?? CurrencySettings())
        return currencyFormatter.formatAmount(amountValue) ?? Constants.valuePlaceholderText
    }

    func formattedConversionString(for conversionRate: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        numberFormatter.minimumFractionDigits = 1

        // do not add 0 fraction digit if the percentage is round
        let minimumFractionDigits = floor(conversionRate * 100.0) == conversionRate * 100.0 ? 0 : 1
        numberFormatter.minimumFractionDigits = minimumFractionDigits
        return numberFormatter.string(from: conversionRate as NSNumber) ?? Constants.valuePlaceholderText
    }

    enum Constants {
        static let valuePlaceholderText = "-"
    }

    enum Localization {
        static let myShop = NSLocalizedString("My Shop", comment: "Generic store name for the store info widget preview")
        static let today = NSLocalizedString("Today", comment: "Range title for the today store info widget")
    }
}
