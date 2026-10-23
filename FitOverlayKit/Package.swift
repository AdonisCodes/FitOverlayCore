// swift-tools-version:6.1
import PackageDescription

/// FitOverlayKit — the platform-agnostic FIT/overlay engine for FitOverlay.
///
/// This package intentionally depends on nothing but the Swift standard library and
/// Foundation so it can be embedded anywhere: the macOS/iOS apps, a Windows build,
/// server-side rendering, or (later) WebAssembly. No Apple-only frameworks
/// (SwiftUI/AppKit/UIKit/AVFoundation/CoreLocation) are allowed in this package.
///
/// Modules:
/// - `FitParser`      — binary .FIT file decoding (header, CRC, record messages)
/// - `FitDataModel`   — activity samples/tracks, interpolation, smoothing
/// - `OverlayLayout`  — serialisable overlay documents: widgets, styles, data bindings
/// - `OverlayTimeSync`— mapping between video time and activity time
/// - `OverlayRender`  — resolves a project + track into per-frame draw commands
/// - `FitOverlayKit`  — umbrella module re-exporting everything above
public let package = Package(
    name: "FitOverlayKit",
    products: [
        .library(
            name: "FitOverlayKit",
            targets: ["FitOverlayKit"]
        ),
    ],
    targets: [
        .target(name: "FitParser"),
        .target(name: "FitDataModel", dependencies: ["FitParser"]),
        .target(name: "OverlayTimeSync"),
        .target(name: "OverlayLayout", dependencies: ["FitDataModel", "OverlayTimeSync"]),
        .target(
            name: "OverlayRender",
            dependencies: ["FitParser", "FitDataModel", "OverlayLayout", "OverlayTimeSync"]
        ),
        .target(
            name: "FitOverlayKit",
            dependencies: ["FitParser", "FitDataModel", "OverlayLayout", "OverlayTimeSync", "OverlayRender"]
        ),
        .testTarget(
            name: "FitOverlayKitTests",
            dependencies: ["FitOverlayKit"]
        ),
    ],
    swiftLanguageModes: [.v5]
)
