import Foundation

enum AppConfig {
    #if DEBUG
    static let baseURL = URL(string: "http://localhost:9994")!
    #else
    static let baseURL = URL(string: "https://airdanger-api.comeodore.services")!
    #endif

    static let apiKey: String? = nil

    static let channel = "kyiv_nebo"

    static func channelURL(_ name: String = channel) -> URL {
        URL(string: "https://t.me/\(name)")!
    }

    static func channelDeepLink(_ name: String = channel) -> URL? {
        URL(string: "tg://resolve?domain=\(name)")
    }
}
