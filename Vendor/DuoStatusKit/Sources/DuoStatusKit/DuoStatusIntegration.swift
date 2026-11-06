// LogiHide integration, 2026-11-06. DuoBar source remains under its MIT license.
import AppKit
import SwiftUI

@MainActor
struct DuoStatusActions {
    let openSettings: () -> Void
    let openLayout: () -> Void
    let toggleHiddenItems: () -> Void
}

/// Borrows holzBar's existing control item; never creates a second menu bar icon.
@MainActor
public final class DuoStatusIntegration {
    private let store: SystemStatusStore
    private let controller: MenuBarController
    private var wakeObserver: NSObjectProtocol?

    public init(
        statusItem: NSStatusItem,
        openSettings: @escaping () -> Void,
        openLayout: @escaping () -> Void,
        toggleHiddenItems: @escaping () -> Void,
        startServices: Bool = true
    ) {
        Self.registerDefaults()
        let store = SystemStatusStore(startServices: startServices)
        self.store = store
        controller = MenuBarController(
            statusStore: store,
            statusItem: statusItem,
            actions: DuoStatusActions(
                openSettings: openSettings,
                openLayout: openLayout,
                toggleHiddenItems: toggleHiddenItems
            )
        )
        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification, object: nil, queue: .main
        ) { [weak store] _ in
            Task { @MainActor in store?.refresh() }
        }
    }

    public func togglePopover() { controller.togglePopover() }

    public func dismissPopover() { controller.dismissPanel() }

    @discardableResult
    public func setNativeIconRequired(_ required: Bool) -> Bool {
        controller.setNativeIconRequired(required)
    }

    public func invalidate() {
        controller.invalidate()
        if let wakeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(wakeObserver)
            self.wakeObserver = nil
        }
    }

    deinit {
        if let wakeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(wakeObserver)
        }
    }

    private static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            PreferenceKeys.showBatteryPercentage: true,
            PreferenceKeys.animationsEnabled: true,
            PreferenceKeys.menuBarIconScale: MenuBarIconSize.defaultScale,
            PreferenceKeys.batteryColorCoding: false,
            PreferenceKeys.openOnHover: false,
            PreferenceKeys.showBatteryPercentageInMenuBar: false
        ])
    }
}

public struct DuoStatusSettings: View {
    public init() {}

    public var body: some View { SettingsView() }
}
