import Foundation
import OSLog

/// Keeps the assertion holder separate from the process that owns LogiHide's status item.
/// macOS 27 can discard the holder's own items even when its bundle is allowlisted.
@available(macOS 27.0, *)
@MainActor
final class IsolatedConcealmentBackend27: ConcealmentBackend27 {
    private final class Token: ConcealmentToken27 {
        let id: String
        let generation: UUID
        init(id: String, generation: UUID) { self.id = id; self.generation = generation }
    }

    nonisolated enum Failure: Error { case missingHelper, disconnected, timedOut, rejected }
    private var process: Process?
    private var input: FileHandle?
    private var reader: Task<Void, Never>?
    private var generation = UUID()
    private var pending: [String: CheckedContinuation<Void, any Error>] = [:]
    private let writes = DispatchQueue(label: "com.logimox.LogiHide.ConcealmentPipe")
    private var shuttingDown = false
    private let logger = Logger(category: "ConcealmentHelper")
    var onUnexpectedExit: (() -> Void)?

    func activate(allowedBundleIDs: [String], allowedSystemItems: [Int]) async throws -> any ConcealmentToken27 {
        try startIfNeeded()
        let token = UUID().uuidString
        let ownID = Bundle.main.bundleIdentifier ?? "com.logimox.LogiHide"
        let command = ConcealmentCommand(
            requestID: UUID().uuidString, operation: .activate, tokenID: token,
            allowedBundleIDs: Set(allowedBundleIDs).union([ownID]).sorted(),
            allowedSystemItems: allowedSystemItems
        )
        try await withCheckedThrowingContinuation { continuation in
            pending[command.requestID] = continuation
            send(command)
            Task { [weak self] in
                try? await Task.sleep(for: .seconds(5))
                self?.pending.removeValue(forKey: command.requestID)?.resume(throwing: Failure.timedOut)
            }
        }
        return Token(id: token, generation: generation)
    }

    func invalidate(_ token: any ConcealmentToken27) {
        guard let token = token as? Token, token.generation == generation, process?.isRunning == true else { return }
        send(ConcealmentCommand(requestID: UUID().uuidString, operation: .invalidate, tokenID: token.id))
    }

    func shutdown() {
        shuttingDown = true
        onUnexpectedExit = nil
        // EOF makes the helper synchronously release all its assertions and terminate.
        try? input?.close()
        input = nil
    }

    private func startIfNeeded() throws {
        if process?.isRunning == true { return }
        shuttingDown = false
        let url = Bundle.main.bundleURL.appending(path: "Contents/Helpers/LogiHideConcealer.app")
        guard let executable = Bundle(url: url)?.executableURL else { throw Failure.missingHelper }
        let child = Process()
        let stdin = Pipe(), stdout = Pipe()
        child.executableURL = executable
        child.standardInput = stdin
        child.standardOutput = stdout
        child.standardError = FileHandle.standardError
        try child.run()
        generation = UUID()
        let childGeneration = generation
        process = child
        input = stdin.fileHandleForWriting
        let output = stdout.fileHandleForReading
        reader = Task { [weak self] in
            do {
                for try await line in output.bytes.lines {
                    guard let data = line.data(using: .utf8),
                          let reply = try? JSONDecoder().decode(ConcealmentReply.self, from: data)
                    else { continue }
                    self?.receive(reply, generation: childGeneration)
                }
            } catch { }
            self?.disconnected(generation: childGeneration)
        }
        logger.notice("Concealment helper started, pid \(child.processIdentifier, privacy: .public)")
    }

    private func send(_ command: ConcealmentCommand) {
        guard let handle = input, let data = try? JSONEncoder().encode(command) else { return }
        let message = data + Data([10])
        writes.async { try? handle.write(contentsOf: message) }
    }

    private func receive(_ reply: ConcealmentReply, generation: UUID) {
        guard generation == self.generation, let continuation = pending.removeValue(forKey: reply.requestID) else { return }
        if reply.succeeded { continuation.resume() }
        else { continuation.resume(throwing: Failure.rejected) }
    }

    private func disconnected(generation: UUID) {
        guard generation == self.generation else { return }
        input = nil
        process = nil
        let waiting = pending.values
        pending.removeAll()
        for continuation in waiting { continuation.resume(throwing: Failure.disconnected) }
        if !shuttingDown { onUnexpectedExit?() }
    }
}
