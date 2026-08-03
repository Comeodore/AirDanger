import Foundation

struct DeviceRegistration: Codable, Equatable {
    let token: String
}

extension Data {
    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
