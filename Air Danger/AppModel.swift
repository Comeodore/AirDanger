import Foundation
import Observation
import os
import UIKit
import UserNotifications

enum AlertsFeed: Equatable {
    case loading
    case loaded([ThreatAlert])
    case unavailable
}

@Observable
final class AppModel {
    static let shared = AppModel()

    private let api = APIClient()
    private let logger = Logger(subsystem: "comeodore.airdanger", category: "app")
    private let defaults = UserDefaults.standard

    private init() {
        notificationsEnabled = defaults.object(forKey: "notificationsEnabled") as? Bool ?? true
    }

    var onboarded: Bool {
        get { defaults.bool(forKey: "onboarded") }
        set { defaults.set(newValue, forKey: "onboarded") }
    }

    private var deviceToken: String? {
        get { defaults.string(forKey: "deviceToken") }
        set { defaults.set(newValue, forKey: "deviceToken") }
    }

    var notificationsEnabled: Bool {
        didSet { defaults.set(notificationsEnabled, forKey: "notificationsEnabled") }
    }

    var alertsFeed: AlertsFeed = .loading

    func refreshAlerts() async {
        do {
            alertsFeed = .loaded(try await api.alerts())
        } catch {
            logger.error("alerts refresh failed: \(error)")
            if case .loaded = alertsFeed {} else {
                alertsFeed = .unavailable
            }
        }
    }

    func sendTestNotification() async {
        let center = UNUserNotificationCenter.current()
        if await center.notificationSettings().authorizationStatus == .notDetermined {
            _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
            await refreshNotificationStatus()
        }
        let content = UNMutableNotificationContent()
        content.title = "Тестове сповіщення"
        content.body = "Так виглядатиме сповіщення про підтверджений пуск — зі звуком на рівні гучності дзвінка."
        content.sound = UNNotificationSound(named: UNNotificationSoundName("alert.caf"))
        content.userInfo = ["test": true]
        let request = UNNotificationRequest(
            identifier: "test-notification", content: content, trigger: nil
        )
        do {
            try await center.add(request)
        } catch {
            logger.error("test notification failed: \(error)")
        }
    }

    func enableNotifications() async {
        do {
            let center = UNUserNotificationCenter.current()
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            notificationsEnabled = granted
        } catch {
            logger.error("notification authorization failed: \(error)")
        }
        UIApplication.shared.registerForRemoteNotifications()
    }

    func refreshNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        notificationsEnabled = settings.authorizationStatus == .authorized
            || settings.authorizationStatus == .provisional
    }

    func handleDeviceToken(_ tokenData: Data) async {
        let token = tokenData.hexString
        deviceToken = token
        do {
            try await api.register(registrationBody(token: token))
            logger.info("device registered")
        } catch {
            logger.error("device registration failed: \(error)")
        }
    }

    func registrationBody(token: String) -> DeviceRegistration {
        DeviceRegistration(token: token)
    }
}
