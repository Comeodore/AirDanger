import Foundation

struct DeviceRegistration: Codable, Equatable {
    let token: String
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

extension Data {
    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
