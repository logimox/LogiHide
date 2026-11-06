import AppKit
import SwiftUI
import XCTest
@testable import DuoStatusKit

final class LogiHideIntegrationTests: XCTestCase {
    @MainActor
    func testBorrowedStatusItemKeepsItsOwnerAndSurvivesInvalidation() throws {
        _ = NSApplication.shared
        let item = NSStatusBar.system.statusItem(withLength: 24)
        defer { NSStatusBar.system.removeStatusItem(item) }
        let owner = NSObject()
        let action = NSSelectorFromString("originalAction:")
        let button = try XCTUnwrap(item.button)
        button.target = owner
        button.action = action
        let integration = DuoStatusIntegration(
            statusItem: item, openSettings: {}, openLayout: {},
            toggleHiddenItems: {}, startServices: false
        )
        XCTAssertTrue(button.target === owner)
        XCTAssertEqual(button.action, action)
        XCTAssertFalse(button.subviews.isEmpty)
        XCTAssertGreaterThan(item.length, 1)
        integration.invalidate()
        integration.invalidate()
        XCTAssertTrue(item.isVisible)
        XCTAssertTrue(button.target === owner)
        XCTAssertEqual(button.action, action)
        XCTAssertFalse(button.subviews.contains { $0 is NSHostingView<DuoStatusView> })
    }

    func testBundledSwedishHidingActionsAreTranslated() throws {
        let path = try XCTUnwrap(Bundle.module.path(forResource: "sv", ofType: "lproj"))
        let bundle = try XCTUnwrap(Bundle(path: path))
        XCTAssertEqual(NSLocalizedString("Show / Hide Icons", bundle: bundle, comment: ""), "Visa / dölj ikoner")
        XCTAssertEqual(NSLocalizedString("Manage Menu Bar Icons", bundle: bundle, comment: ""), "Hantera menyfältsikoner")
    }

    @MainActor
    func testConcealmentSuppliesANativeImageAndRetainsClickOwnership() throws {
        _ = NSApplication.shared
        let item = NSStatusBar.system.statusItem(withLength: 27)
        defer { NSStatusBar.system.removeStatusItem(item) }
        let owner = NSObject()
        let action = NSSelectorFromString("originalAction:")
        let button = try XCTUnwrap(item.button)
        button.target = owner
        button.action = action
        let integration = DuoStatusIntegration(
            statusItem: item, openSettings: {}, openLayout: {},
            toggleHiddenItems: {}, startServices: false
        )
        defer { integration.invalidate() }
        integration.setNativeIconRequired(true)
        let image = try XCTUnwrap(button.image, "MenuBarAgent needs an NSButton image while concealing")
        let bitmap = try XCTUnwrap(image.tiffRepresentation.flatMap(NSBitmapImageRep.init(data:)))
        let hasVisiblePixels = (0..<bitmap.pixelsWide).contains { x in
            (0..<bitmap.pixelsHigh).contains { y in
                (bitmap.colorAt(x: x, y: y)?.alphaComponent ?? 0) > 0.1
            }
        }
        XCTAssertTrue(hasVisiblePixels)
        XCTAssertGreaterThan(item.length, 1)
        XCTAssertTrue(button.target === owner)
        XCTAssertEqual(button.action, action)
        XCTAssertTrue(button.subviews.contains { $0 is NSHostingView<DuoStatusView> && $0.isHidden })
        integration.setNativeIconRequired(false)
        XCTAssertNil(button.image)
        XCTAssertTrue(button.subviews.contains { $0 is NSHostingView<DuoStatusView> && !$0.isHidden })
    }
}
