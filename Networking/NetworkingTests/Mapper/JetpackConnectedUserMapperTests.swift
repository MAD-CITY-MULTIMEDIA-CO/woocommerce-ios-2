import XCTest
@testable import Networking

/// JetpackConnectedUserMapper Unit Tests
///
final class JetpackConnectedUserMapperTests: XCTestCase {

    func test_all_fields_are_parsed_properly_when_user_is_connected() throws {
        // Given
        let user = try mapUserFromMockResponse()
        let wpcomUser = try XCTUnwrap(user.wpcomUser)

        // Then
        XCTAssertEqual(user.username, "admin")
        XCTAssertEqual(user.gravatar, "<img alt='' src='http://2.gravatar.com/avatar/5e1a8fhjd'/>")
        XCTAssertTrue(user.isMaster)
        XCTAssertTrue(user.isConnected)

        XCTAssertEqual(wpcomUser.id, 223)
        XCTAssertEqual(wpcomUser.username, "test")
        XCTAssertEqual(wpcomUser.siteCount, 12)
        XCTAssertEqual(wpcomUser.email, "test@gmail.com")
        XCTAssertEqual(wpcomUser.displayName, "Test")
        XCTAssertEqual(wpcomUser.textDirection, "ltr")
        XCTAssertEqual(wpcomUser.avatar, "http://2.gravatar.com/avatar/5e1a8fhjd")
    }

    func test_all_fields_are_parsed_properly_when_user_is_not_connected() throws {
        // Given
        let user = try mapNotConnectedUserFromMockResponse()

        // Then
        XCTAssertFalse(user.isMaster)
        XCTAssertFalse(user.isConnected)
        XCTAssertEqual(user.username, "test")
        XCTAssertEqual(user.gravatar, "https://secure.gravatar.com/avatar/a7839e14")
        XCTAssertNil(user.wpcomUser)
    }
}

private extension JetpackConnectedUserMapperTests {
    func mapUserFromMockResponse() throws -> JetpackConnectedUser {
        guard let response = Loader.contentsOf("jetpack-connected-user") else {
            throw FileNotFoundError()
        }

        return try JetpackConnectedUserMapper().map(response: response)
    }

    func mapNotConnectedUserFromMockResponse() throws -> JetpackConnectedUser {
        guard let response = Loader.contentsOf("jetpack-user-not-connected") else {
            throw FileNotFoundError()
        }

        return try JetpackConnectedUserMapper().map(response: response)
    }

    struct FileNotFoundError: Error {}
}
