import Foundation

protocol AnalyticsHubTimeRangeData {
    var currentDateStart: Date? { get }
    var currentDateEnd: Date? { get }
    var previousDateStart: Date? { get }
    var previousDateEnd: Date? { get }

    init(referenceDate: Date, timezone: TimeZone, calendar: Calendar)
}

extension AnalyticsHubTimeRangeData {
    var currentTimeRange: AnalyticsHubTimeRange? {
        generateTimeRangeFrom(startDate: currentDateStart, endDate: currentDateEnd)
    }

    var previousTimeRange: AnalyticsHubTimeRange? {
        generateTimeRangeFrom(startDate: previousDateStart, endDate: previousDateEnd)
    }

    private func generateTimeRangeFrom(startDate: Date?, endDate: Date?) -> AnalyticsHubTimeRange? {
        if let startDate = startDate,
           let endDate = endDate {
            return AnalyticsHubTimeRange(start: startDate, end: endDate)
        } else {
            return nil
        }
    }
}