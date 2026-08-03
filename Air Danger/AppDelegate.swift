import os
import UIKit
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private let logger = Logger(subsystem: "comeodore.airdanger", category: "push")

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Task { await AppModel.shared.handleDeviceToken(deviceToken) }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logger.error("remote notifications registration failed: \(error)")
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let source = response.notification.request.content.userInfo["source"] as? String
        let channel = (source?.isEmpty == false) ? source! : AppConfig.channel
        await openChannel(channel)
    }

    @MainActor
    private func openChannel(_ channel: String) {
        let web = AppConfig.channelURL(channel)
        guard let deepLink = AppConfig.channelDeepLink(channel) else {
            UIApplication.shared.open(web)
            return
        }
        UIApplication.shared.open(deepLink) { opened in
            if !opened {
                UIApplication.shared.open(web)
            }
        }
    }
}
