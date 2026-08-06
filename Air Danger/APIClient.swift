import Foundation

struct APIClient {
    var baseURL = AppConfig.baseURL

    func register(_ registration: DeviceRegistration) async throws {
        var request = makeRequest(path: "/devices")
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(registration)
        try await send(request)
    }

    @discardableResult
    private func send(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
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
