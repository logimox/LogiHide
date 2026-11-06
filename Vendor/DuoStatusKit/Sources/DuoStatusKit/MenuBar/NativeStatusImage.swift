// LogiHide, 2026-11-06. The assessment-mode menu bar forwards NSButton.image,
// rather than arbitrary subviews of its status button, to MenuBarAgent.
import AppKit
import SwiftUI

@MainActor
enum NativeStatusImage {
    static func render(store: SystemStatusStore, appearance: NSAppearance?) -> NSImage? {
        let defaults = UserDefaults.standard
        let metrics = DuoGlyphMetrics.standard.scaled(by: MenuBarIconSize.storedScale())
        let batteryColors = defaults.bool(forKey: PreferenceKeys.batteryColorCoding)
        let adaptiveColors = defaults.bool(forKey: PreferenceKeys.adaptiveRingColorCoding)
        let adaptive = store.usesReleasedAdaptiveRing
        let ring: DuoPersistentRingPresentation = adaptive
            ? .adaptive(progress: AdaptiveRingVisualTarget(state: AdaptiveRingMonitor.shared.state).progress)
            : .battery(store.status.battery, colorCodingEnabled: batteryColors)
        let ringColor = adaptive ? AdaptiveRingColorResolver.resolve(
            state: AdaptiveRingMonitor.shared.state,
            decision: AdaptiveRingMonitor.shared.performanceDecision,
            colorCodingEnabled: adaptiveColors
        ).color : nil
        let dark = appearance?.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        let content = DuoGlyphView(
            status: store.status,
            presentation: store.priorityController.presentation,
            metrics: metrics,
            animationsEnabled: false,
            ringPresentation: ring,
            ringColorOverride: ringColor,
            batteryColorCodingEnabled: batteryColors,
            showBatteryPercentage: defaults.bool(forKey: PreferenceKeys.showBatteryPercentageInMenuBar)
        )
        .offset(y: DuoGlyphMetrics.menuBarVerticalOffset)
        .frame(width: metrics.statusItemWidth, height: 22)
        .environment(\.colorScheme, dark ? .dark : .light)
        let renderer = ImageRenderer(content: content)
        renderer.scale = NSScreen.main?.backingScaleFactor ?? 2
        guard let image = renderer.nsImage else { return nil }
        image.isTemplate = !(batteryColors || (adaptive && adaptiveColors))
        return image
    }
}
