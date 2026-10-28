// swift-tools-version:6.2.3
import PackageDescription

/// Initializes Package
public let package = Package(
    name: "Backend",
    platforms: [
        .macOS(.v15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.113.2"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.12.0"),
        .package(url: "https://github.com/GetAutomaApp/TwitterAPIKit", from: "1.0.0"),
        // 🐘 Fluent driver for Postgres.
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.10.0"),
        // 🍃 An expressive, performant, and extensible templating language built for Swift.
        .package(url: "https://github.com/vapor/leaf.git", from: "4.4.1"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        .package(path: "./DataTypes"),
        .package(url: "https://github.com/vapor/jwt.git", from: "5.1.2"),
        .package(url: "https://github.com/MacPaw/OpenAI.git", from: "0.4.5"),
        .package(url: "https://github.com/soto-project/soto.git", from: "7.3.0"),
        .package(url: "https://github.com/swift-server/swift-prometheus.git", from: "2.0.0"),
        .package(url: "https://github.com/nmdias/FeedKit.git", from: "10.0.0-rc.3"),
        .package(url: "https://github.com/GetAutomaApp/swift-retry.git", branch: "main"),
        .package(url: "https://github.com/GetAutomaApp/Fakery", branch: "master"),
        .package(url: "https://github.com/GetAutomaApp/AutomaUtilities", branch: "main"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.11.1"),
        .package(url: "https://github.com/lovetodream/swift-log-loki.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-temporal-sdk.git", from: "0.6.0"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "DataTypes", package: "DataTypes"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "OpenAI", package: "OpenAI"),
                .product(name: "TwitterAPIKit", package: "TwitterAPIKit"),
                .product(name: "SotoS3", package: "soto"),
                .product(name: "SotoSNS", package: "soto"),
                .product(name: "Prometheus", package: "swift-prometheus"),
                .product(name: "SotoTextract", package: "soto"),
                .product(name: "FeedKit", package: "FeedKit"),
                .product(name: "DMRetry", package: "swift-retry"),
                .product(name: "AutomaUtilities", package: "AutomaUtilities"),
                "SwiftSoup",
                .product(name: "LoggingLoki", package: "swift-log-loki"),
                .product(name: "Temporal", package: "swift-temporal-sdk"),
            ],
            exclude: [
                "Documentation.md"
            ],
            swiftSettings: swiftSettings,
            linkerSettings: [
                .linkedLibrary("crypto", .when(platforms: [.linux])),
                .linkedLibrary("icudata", .when(platforms: [.linux])),
                .linkedLibrary("icuuc", .when(platforms: [.linux])),
                .linkedLibrary("ssl", .when(platforms: [.linux])),
                .linkedLibrary("z", .when(platforms: [.linux])),
            ]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "VaporTesting", package: "vapor"),
                .product(name: "Fakery", package: "Fakery"),
            ],
            swiftSettings: swiftSettings
        ),
    ],
    swiftLanguageModes: [.v5]
)

/// Default swift settings
public var swiftSettings: [SwiftSetting] {
    [
        .enableUpcomingFeature("DisableOutwardActorInference"),
        .enableExperimentalFeature("StrictConcurrency"),
    ]
}
