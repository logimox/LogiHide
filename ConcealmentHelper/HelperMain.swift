import AppKit
import Foundation

// A background app with no windows or menu bar items. Its only input is its parent's pipe.
@main
enum HelperMain {
    @MainActor static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        Task {
            let backend = MenuBarAssessmentAssertion27()
            var tokens: [String: any ConcealmentToken27] = [:]
            do {
                for try await line in FileHandle.standardInput.bytes.lines {
                    guard let data = line.data(using: .utf8),
                          let command = try? JSONDecoder().decode(ConcealmentCommand.self, from: data),
                          command.isValid else { continue }
                    var reply = ConcealmentReply(requestID: command.requestID, succeeded: true)
                    do {
                        switch command.operation {
                        case .activate:
                            let token = try await backend.activate(
                                allowedBundleIDs: command.allowedBundleIDs,
                                allowedSystemItems: command.allowedSystemItems
                            )
                            if let previous = tokens.updateValue(token, forKey: command.tokenID) {
                                backend.invalidate(previous)
                            }
                        case .invalidate:
                            if let token = tokens.removeValue(forKey: command.tokenID) { backend.invalidate(token) }
                        }
                    } catch {
                        reply = ConcealmentReply(requestID: command.requestID, succeeded: false, error: "activation failed")
                    }
                    if let data = try? JSONEncoder().encode(reply) {
                        try? FileHandle.standardOutput.write(contentsOf: data + Data([10]))
                    }
                }
            } catch { }
            for token in tokens.values { backend.invalidate(token) }
            app.terminate(nil)
        }
        app.run()
    }
}
