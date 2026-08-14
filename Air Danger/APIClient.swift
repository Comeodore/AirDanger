import Foundation

enum APIError: Error, Equatable {
    case status(Int)
}

struct APIClient {
    var baseURL = AppConfig.baseURL

    private static let decoder: JSONDecoder = {
        let plain = ISO8601DateFormatter()
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            guard let date = plain.date(from: raw) ?? fractional.date(from: raw) else {
                throw DecodingError.dataCorruptedError(
                    in: container, debugDescription: "unrecognized timestamp \(raw)"
                )
            }
            return date
        }
        return decoder
    }()

    func register(_ registration: DeviceRegistration) async throws {
        var request = makeRequest(path: "/devices")
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(registration)
        try await send(request)
    }

    func updateDevice(_ prefs: DevicePrefs, token: String) async throws {
        var request = makeRequest(path: "/devices/\(token)")
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(prefs)
        try await send(request)
    }

    func alerts(limit: Int = 50, before: Int? = nil) async throws -> [ThreatAlert] {
        var request = makeRequest(path: "/alerts")
        var query = [URLQueryItem(name: "limit", value: String(limit))]
        if let before {
            query.append(URLQueryItem(name: "before", value: String(before)))
        }
        request.url?.append(queryItems: query)
        let data = try await send(request)
        return try Self.decoder.decode(AlertsResponse.self, from: data).alerts
    }

    @discardableResult
    private func send(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.status(http.statusCode)
        }
        return data
    }

    private func makeRequest(path: String) -> URLRequest {
        var request = URLRequest(url: baseURL.appending(path: path))
        if let key = AppConfig.apiKey {
            request.setValue(key, forHTTPHeaderField: "X-API-Key")
        }
        return request
    }
}
