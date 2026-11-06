// swift-tools-version: 5.9
import PackageDescription

// A local, vendored copy of DuoBar's MIT-licensed status UI and services.
// Its original Swift 5 language mode is isolated from holzBar's Swift 6 target.
let package = Package(
    name: "DuoStatusKit",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    products: [.library(name: "DuoStatusKit", targets: ["DuoStatusKit"])],
    targets: [
        .target(name: "DuoStatusKit", resources: [.process("Resources")]),
        .testTarget(name: "DuoStatusKitTests", dependencies: ["DuoStatusKit"])
    ],
    swiftLanguageVersions: [.v5]
)
