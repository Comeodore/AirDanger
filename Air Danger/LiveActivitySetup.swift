import ActivityKit
import Foundation

extension AppModel {
    func watchLiveActivityTokens() {
        Task {
            for await tokenData in Activity<ThreatActivityAttributes>.pushToStartTokenUpdates {
                await storeLiveActivityToken(tokenData.hexString, key: "laStartToken")
            }
        }
        Task {
            for activity in Activity<ThreatActivityAttributes>.activities {
                watchPushToken(of: activity)
            }
            for await activity in Activity<ThreatActivityAttributes>.activityUpdates {
                watchPushToken(of: activity)
            }
        }
    }

    private func watchPushToken(of activity: Activity<ThreatActivityAttributes>) {
        Task {
            for await tokenData in activity.pushTokenUpdates {
                await storeLiveActivityToken(tokenData.hexString, key: "laUpdateToken")
            }
        }
    }
}
