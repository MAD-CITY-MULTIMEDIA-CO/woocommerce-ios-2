import Foundation

/// Mapper: Leaderboard List
///
struct LeaderboardListMapper: Mapper {

    /// (Attempts) to convert a dictionary into a Leaderboards entity.
    ///
    func map(response: Data) throws -> [Leaderboard] {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(LeaderboardsEnvelope.self, from: response).data
        } catch {
            return try decoder.decode([Leaderboard].self, from: response)
        }
    }
}

/// LeaderboardEnvelope Disposable Entity
/// `Leaderboards` endpoint returns the requested stats in the `data` key.
///
private struct LeaderboardsEnvelope: Decodable {
    let data: [Leaderboard]
}
