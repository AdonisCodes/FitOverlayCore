// swift-tools-version:6.1
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
        // 🐘 Fluent driver for Postgres.
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.10.0"),
        // 🍃 An expressive, performant, and extensible templating language built for Swift.
        .package(url: "https://github.com/vapor/leaf.git", from: "4.4.1"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        .package(path: "./DataTypes"),
        .package(url: "https://github.com/vapor/jwt.git", from: "5.1.2"),
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
            ],
            swiftSettings: swiftSettings,
            linkerSettings: [
                .linkedLibrary("crypto", .when(platforms: [.linux])),
                .linkedLibrary("ssl", .when(platforms: [.linux])),
                .linkedLibrary("z", .when(platforms: [.linux])),
            ]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "VaporTesting", package: "vapor"),
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
