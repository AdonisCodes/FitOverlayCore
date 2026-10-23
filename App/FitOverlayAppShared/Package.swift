// swift-tools-version: 6.0

import PackageDescription

/// FitOverlayAppShared Package Definition
/// This package contains shared components and utilities for the FitOverlay macOS and iOS applications.
///
/// The package includes:
/// - Network communication utilities using Alamofire
/// - UI components from FitOverlayUIKit
/// - Data models from DataTypes
/// - Secure storage functionality using SimpleKeychain
public let package = Package(
    // Name of the Swift package
    name: "FitOverlayAppShared",

    // Supported platforms and their minimum versions
    platforms: [
        .iOS(.v17), // Requires iOS 17.0 or later
        .macOS(.v15), // Requires macOS 15.0 or later
    ],

    // Products defined by the package
    products: [
        // Main library product that clients can depend on
        .library(
            name: "FitOverlayAppShared",
            targets: ["FitOverlayAppShared"]
        ),
    ],

    // External package dependencies
    dependencies: [
        // Alamofire for networking
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.0")),

        // Local package dependencies
        .package(path: "../FitOverlayUIKit"),
        .package(path: "../../Backend/DataTypes"),

        // SimpleKeychain for secure storage
        .package(url: "https://github.com/auth0/SimpleKeychain.git", from: "1.2.0"),
    ],

    // Package targets
    targets: [
        // Main target containing the package's source code
        .target(
            name: "FitOverlayAppShared",
            dependencies: [
                // Network communication framework
                .product(name: "Alamofire", package: "Alamofire"),

                // UI components and utilities
                "FitOverlayUIKit",

                // Data model definitions
                .product(name: "DataTypes", package: "DataTypes"),

                // Secure keychain storage
                .product(name: "SimpleKeychain", package: "SimpleKeychain"),
            ],
            path: "Sources",
            exclude: [],
            resources: [
                .process("FitOverlayAppShared/Preview Content/Preview Assets.xcassets"),
            ]
        ),

        // Test target for unit tests
        .testTarget(
            name: "FitOverlayAppSharedTests",
            dependencies: ["FitOverlayAppShared"],
            path: "Tests"
        ),
    ]
)
