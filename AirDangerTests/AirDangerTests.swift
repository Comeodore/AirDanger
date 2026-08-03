import XCTest
@testable import AirDanger

final class RegistrationBodyTests: XCTestCase {
    func testBodyIsBareToken() throws {
        let body = AppModel.shared.registrationBody(token: "ab01")

        XCTAssertEqual(body, DeviceRegistration(token: "ab01"))

        let data = try JSONEncoder().encode(body)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(object["token"] as? String, "ab01")
        XCTAssertEqual(object.count, 1)
    }
}

final class TokenHexTests: XCTestCase {
    func testHexEncoding() {
        XCTAssertEqual(Data([0xAB, 0xCD, 0x01, 0x00]).hexString, "abcd0100")
        XCTAssertEqual(Data().hexString, "")
    }
}

final class ChannelURLTests: XCTestCase {
    func testChannelURLPointsAtTelegram() {
        XCTAssertEqual(AppConfig.channelURL().absoluteString, "https://t.me/kyiv_nebo")
        XCTAssertEqual(AppConfig.channelDeepLink()?.absoluteString, "tg://resolve?domain=kyiv_nebo")
    }
}
