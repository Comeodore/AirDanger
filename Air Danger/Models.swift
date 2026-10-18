import Foundation

enum DeviceInfo {
    static let model: String = {
        if let simulated = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return simulated
        }
        var system = utsname()
        uname(&system)
        return withUnsafeBytes(of: &system.machine) { buffer in
            String(decoding: buffer.prefix { $0 != 0 }, as: UTF8.self)
        }
    }()

    static let iosVersion: String = {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let base = "\(version.majorVersion).\(version.minorVersion)"
        return version.patchVersion > 0 ? "\(base).\(version.patchVersion)" : base
    }()
}

struct DeviceRegistration: Codable, Equatable {
    let token: String
    let warnings: Bool
    let sound: String
    let critical: Bool
    let criticalVolume: Double
    let laStartToken: String?
    let laUpdateToken: String?
    let model: String
    let iosVersion: String

    enum CodingKeys: String, CodingKey {
        case token, warnings, sound, critical, model
        case criticalVolume = "critical_volume"
        case laStartToken = "la_start_token"
        case laUpdateToken = "la_update_token"
        case iosVersion = "ios_version"
    }
}

struct DevicePrefs: Codable, Equatable {
    let warnings: Bool
    let sound: String
    let critical: Bool
    let criticalVolume: Double
    let laStartToken: String?
    let laUpdateToken: String?

    enum CodingKeys: String, CodingKey {
        case warnings, sound, critical
        case criticalVolume = "critical_volume"
        case laStartToken = "la_start_token"
        case laUpdateToken = "la_update_token"
    }
}

struct ThreatAlert: Codable, Equatable, Identifiable {
    let id: Int
    let ts: Date
    let channel: String
    let type: String
    let severity: String
    let text: String
}

struct AlertsResponse: Codable, Equatable {
    let alerts: [ThreatAlert]
}

struct AlertSound: Identifiable, Equatable {
    let file: String
    let name: String

    var id: String { file }

    static let choices = [
        AlertSound(file: "alert.caf", name: "Стандартний"),
        AlertSound(file: "pulse.caf", name: "Імпульс"),
        AlertSound(file: "opovishchennia.caf", name: "Оповіщення"),
    ]

    static func name(of file: String) -> String {
        choices.first { $0.file == file }?.name ?? file
    }
}

extension Data {
    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
