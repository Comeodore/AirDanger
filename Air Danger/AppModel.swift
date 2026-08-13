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

    enum Tab: Hashable {
        case threats
        case settings
    }

    private static let alertsPage = 50

    private let api = APIClient()
    private let logger = Logger(subsystem: "comeodore.airdanger", category: "app")
    private let defaults = UserDefaults.standard

    private init() {
        notificationsEnabled = defaults.object(forKey: "notificationsEnabled") as? Bool ?? true
        warningsEnabled = defaults.object(forKey: "warningsEnabled") as? Bool ?? true
        alertSound = defaults.string(forKey: "alertSound") ?? "alert.caf"
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

    var warningsEnabled: Bool {
        didSet { defaults.set(warningsEnabled, forKey: "warningsEnabled") }
    }

    var alertSound: String {
        didSet { defaults.set(alertSound, forKey: "alertSound") }
    }

    func setWarnings(_ enabled: Bool) async {
        warningsEnabled = enabled
        defaults.set(true, forKey: "prefsDirty")
        await syncPrefs()
    }

    func setSound(_ file: String) async {
        alertSound = file
        defaults.set(true, forKey: "prefsDirty")
        await syncPrefs()
    }

    func syncPrefs() async {
        guard defaults.bool(forKey: "prefsDirty"),
              defaults.bool(forKey: "deviceRegistered"),
              let token = deviceToken else { return }
        do {
            try await api.updateDevice(token: token, warnings: warningsEnabled, sound: alertSound)
            defaults.set(false, forKey: "prefsDirty")
            logger.info("device prefs synced")
        } catch APIError.status(404) {
            logger.warning("prefs sync got 404, re-registering device")
            defaults.set(false, forKey: "deviceRegistered")
            await MainActor.run {
                UIApplication.shared.registerForRemoteNotifications()
            }
        } catch {
            logger.error("prefs sync failed: \(error)")
        }
    }

    var alertsFeed: AlertsFeed = .loading
    var selectedTab: Tab = .threats
    private(set) var alertsExhausted = false
    private var loadingMoreAlerts = false

    func refreshAlerts() async {
        do {
            let page = try await api.alerts(limit: Self.alertsPage)
            if case .loaded(let existing) = alertsFeed, let oldest = page.last {
                let tail = existing.filter { $0.id < oldest.id }
                alertsFeed = .loaded(page + tail)
            } else {
                alertsFeed = .loaded(page)
                alertsExhausted = page.count < Self.alertsPage
            }
        } catch {
            logger.error("alerts refresh failed: \(error)")
            if case .loaded = alertsFeed {} else {
                alertsFeed = .unavailable
            }
        }
    }

    func loadMoreAlerts() async {
        guard case .loaded(let alerts) = alertsFeed, let last = alerts.last,
              !alertsExhausted, !loadingMoreAlerts else { return }
        loadingMoreAlerts = true
        defer { loadingMoreAlerts = false }
        do {
            let page = try await api.alerts(limit: Self.alertsPage, before: last.id)
            alertsExhausted = page.count < Self.alertsPage
            if case .loaded(let current) = alertsFeed {
                alertsFeed = .loaded(current + page.filter { $0.id < last.id })
            }
        } catch {
            logger.error("alerts page failed: \(error)")
        }
    }

    @MainActor
    func openChannel(_ channel: String) {
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

    func sendTestNotification() async {
        let center = UNUserNotificationCenter.current()
        if await center.notificationSettings().authorizationStatus == .notDetermined {
            _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
            await refreshNotificationStatus()
        }
        let content = UNMutableNotificationContent()
        content.title = "Тестове сповіщення"
        content.body = "Так виглядатиме сповіщення про підтверджений пуск — зі звуком на рівні гучності дзвінка."
        content.sound = UNNotificationSound(named: UNNotificationSoundName(alertSound))
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
            defaults.set(true, forKey: "deviceRegistered")
            logger.info("device registered")
            await syncPrefs()
        } catch {
            defaults.set(false, forKey: "deviceRegistered")
            logger.error("device registration failed: \(error)")
        }
    }

    func registrationBody(token: String) -> DeviceRegistration {
        DeviceRegistration(token: token)
    }
}
