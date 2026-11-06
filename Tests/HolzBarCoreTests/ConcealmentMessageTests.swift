import Foundation
import Testing
@testable import HolzBarCore

struct ConcealmentMessageTests {
    @Test func preservesAllowlistAndRequestIdentity() throws {
        let command = ConcealmentCommand(
            requestID: UUID().uuidString, operation: .activate, tokenID: UUID().uuidString,
            allowedBundleIDs: ["com.logimox.LogiHide", "com.apple.weather.menu"],
            allowedSystemItems: Array(0..<128)
        )
        let decoded = try JSONDecoder().decode(ConcealmentCommand.self, from: JSONEncoder().encode(command))
        #expect(decoded.isValid)
        #expect(decoded.allowedBundleIDs == command.allowedBundleIDs)
        #expect(decoded.allowedSystemItems == command.allowedSystemItems)
        #expect(decoded.requestID == command.requestID)
        #expect(decoded.tokenID == command.tokenID)
    }

    @Test func rejectsInvalidIdentityAndUnboundedInputs() {
        var command = ConcealmentCommand(requestID: "bad", operation: .activate, tokenID: UUID().uuidString)
        #expect(!command.isValid)
        command = ConcealmentCommand(requestID: UUID().uuidString, operation: .activate, tokenID: UUID().uuidString)
        command.allowedSystemItems = [-1, 128]
        #expect(!command.isValid)
        command.allowedSystemItems = []
        command.allowedBundleIDs = [String(repeating: "x", count: 513)]
        #expect(!command.isValid)
    }
}
