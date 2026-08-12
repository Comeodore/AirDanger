import Foundation

struct DeviceRegistration: Codable, Equatable {
    let token: String
}

struct ThreatAlert: Codable, Equatable, Identifiable {
    let ts: Date
    let channel: String
    let type: String
    let severity: String
    let text: String

    var id: String { "\(ts.timeIntervalSince1970)-\(severity)-\(text)" }
}

struct AlertsResponse: Codable, Equatable {
    let alerts: [ThreatAlert]
}

extension Data {
    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
