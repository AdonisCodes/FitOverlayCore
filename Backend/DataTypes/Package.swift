// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// The main package manifest for the DataTypes library.
/// This package provides core data type definitions and utilities used across the application.
///
/// The package requires:
/// - macOS 15.0 or later
/// - iOS 17.0 or later
///
/// Dependencies:
/// - Vapor: Web framework for Swift
/// - JWT: JSON Web Token implementation
/// - Alamofire: HTTP networking library
/// - PhoneNumberKit: Phone number parsing and validation
public let package = Package(
    name: "DataTypes",
    platforms: [
        .macOS(.v15), // Minimum macOS version requirement
        .iOS(.v17), // Minimum iOS version requirement
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DataTypes", // Main library product
            targets: ["DataTypes"] // Associated target
        ),
    ],
    dependencies: [
        /// Vapor framework dependency for server-side Swift development
        .package(url: "https://github.com/vapor/vapor.git", from: "4.99.3"),

        /// JWT framework for handling JSON Web Tokens
        .package(url: "https://github.com/vapor/jwt.git", from: "5.0.0"),

        /// Alamofire for simplified HTTP networking
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.0")),

        /// PhoneNumberKit for phone number handling and validation
        .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "4.0.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DataTypes", // Main target name
            dependencies: [
                /// Vapor framework integration
                .product(name: "Vapor", package: "vapor"),

                /// JWT functionality for authentication
                .product(name: "JWT", package: "jwt"),

                /// Networking capabilities
                .product(name: "Alamofire", package: "Alamofire"),

                /// Phone number parsing and validation
                .product(name: "PhoneNumberKit", package: "PhoneNumberKit"),
            ]
        ),
    ]
)
