import Foundation

enum AppConfig {
    static let baseURL = URL(string: "https://airdanger-api.comeodore.services")!

    static let apiKey: String? = nil

    static let channel = "kyiv_nebo"

    static func channelURL(_ name: String = channel) -> URL {
        URL(string: "https://t.me/\(name)")!
    }

    static func channelDeepLink(_ name: String = channel) -> URL? {
        URL(string: "tg://resolve?domain=\(name)")
    }
}
