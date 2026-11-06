import Foundation

/// Private parent/child pipe protocol. No socket, service registration or shared files.
nonisolated struct ConcealmentCommand: Codable, Sendable {
    nonisolated enum Operation: String, Codable, Sendable { case activate, invalidate }
    let requestID: String
    let operation: Operation
    let tokenID: String
    var allowedBundleIDs: [String] = []
    var allowedSystemItems: [Int] = []

    var isValid: Bool {
        UUID(uuidString: requestID) != nil && UUID(uuidString: tokenID) != nil
            && allowedBundleIDs.count <= 4096
            && allowedBundleIDs.allSatisfy { !$0.isEmpty && $0.utf8.count <= 512 }
            && allowedSystemItems.count <= 128
            && allowedSystemItems.allSatisfy { (0..<128).contains($0) }
    }
}

nonisolated struct ConcealmentReply: Codable, Sendable {
    let requestID: String
    let succeeded: Bool
    var error: String? = nil
}
