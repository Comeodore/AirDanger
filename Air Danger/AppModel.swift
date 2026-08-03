import Foundation
import Observation
import os
import UIKit
import UserNotifications

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
