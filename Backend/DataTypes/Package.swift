// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// The main package manifest for the DataTypes library.
/// This package provides core data type definitions and utilities shared between the
/// FitOverlay backend and the client applications.
///
/// The package requires:
/// - macOS 15.0 or later
/// - iOS 17.0 or later
/// - Linux (for the backend and CI)
///
/// Dependencies:
/// - Vapor: Web framework for Swift
/// - JWT: JSON Web Token implementation
/// - Alamofire: HTTP networking library (Linux support since 5.10)
public let package = Package(
    name: "DataTypes",
    platforms: [
        .macOS(.v15),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "DataTypes",
            targets: ["DataTypes"]
        ),
    ],
    dependencies: [
        /// Vapor framework dependency for server-side Swift development
        .package(url: "https://github.com/vapor/vapor.git", from: "4.99.3"),

        /// JWT framework for handling JSON Web Tokens
        .package(url: "https://github.com/vapor/jwt.git", from: "5.0.0"),

        /// Alamofire for simplified HTTP networking
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.0")),
    ],
    targets: [
        .target(
            name: "DataTypes",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "Alamofire", package: "Alamofire"),
            ]
        ),
    ]
)
