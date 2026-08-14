import ActivityKit
import Foundation

nonisolated struct ThreatActivityAttributes: ActivityAttributes {
    nonisolated struct ContentState: Codable, Hashable {
        var state: String
        var type: String
        var severity: String
        var text: String
        var count: Int
        var startedAt: Double
        var escalatedAt: Double?
        var lastAt: Double?
    }

    var episode: Int
}
