import Networking

/// Orchestrator class that fetches today store stats data.
///
final class StoreInfoDataService {

    /// Data extracted from networking types.
    ///
    struct Stats {
        let revenue: Decimal
        let totalOrders: Int
        let totalVisitors: Int
        let conversion: Double
    }

    /// Revenue & Orders remote source.
    ///
    private var orderStatsRemoteV4: OrderStatsRemoteV4

    /// Visitors remote source
    ///
    private var siteStatsRemote: SiteStatsRemote

    /// Network helper.
    ///
    private var network: AlamofireNetwork

    init(authToken: String) {
        network = AlamofireNetwork(credentials: Credentials(authToken: authToken))
        orderStatsRemoteV4 = OrderStatsRemoteV4(network: network)
        siteStatsRemote = SiteStatsRemote(network: network)
    }

    /// Async function that fetches todays stats data.
    ///
    func fetchTodayStats(for storeID: Int64) async throws -> Stats {
        // Prepare them to run in parallel
        async let revenueAndOrdersRequest = fetchTodaysRevenueAndOrders(for: storeID)
        async let siteStatsRequest = fetchTodaysVisitors(for: storeID)

        // Wait for for response
        let (revenueAndOrders, siteStats) = try await (revenueAndOrdersRequest, siteStatsRequest)

        // Assemble stats data
        let conversion = siteStats.visitors > 0 ? Double(revenueAndOrders.totals.totalOrders) / Double(siteStats.visitors) : 0
        return Stats(revenue: revenueAndOrders.totals.grossRevenue,
                     totalOrders: revenueAndOrders.totals.totalOrders,
                     totalVisitors: siteStats.visitors,
                     conversion: min(conversion, 1))
    }
}

/// Async Wrappers
///
private extension StoreInfoDataService {

    /// Async wrapper that fetches todays revenues & orders.
    ///
    func fetchTodaysRevenueAndOrders(for storeID: Int64) async throws -> OrderStatsV4 {
        try await withCheckedThrowingContinuation { continuation in
            // `WKWebView` is accessed internally, we are forced to dispatch the call in the main thread.
            Task { @MainActor in
                orderStatsRemoteV4.loadOrderStats(for: storeID,
                                                  unit: .hourly,
                                                  earliestDateToInclude: Date().startOfDay(timezone: .current),
                                                  latestDateToInclude: Date().endOfDay(timezone: .current),
                                                  quantity: 24,
                                                  forceRefresh: true) { result in
                    continuation.resume(with: result)
                }
            }
        }
    }

    /// Async wrapper that fetches todays visitors.
    ///
    func fetchTodaysVisitors(for storeID: Int64) async throws -> SiteSummaryStats {
        try await withCheckedThrowingContinuation { continuation in
            // `WKWebView` is accessed internally, we are forced to dispatch the call in the main thread.
            Task { @MainActor in
                siteStatsRemote.loadSiteSummaryStats(for: storeID,
                                                     period: .day,
                                                     includingDate: Date().endOfDay(timezone: .current)) { result in
                    continuation.resume(with: result)
                }
            }
        }
    }
}
