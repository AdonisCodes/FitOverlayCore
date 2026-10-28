// TwitterClientTestSuite.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

@testable import App
import Testing
import VaporTesting

/// Protocol defining common functionality for Twitter client test suites
/// This protocol provides shared test utilities used across different Twitter client implementations
@Suite(.serialized)
internal struct SerialDbTestSuites {}

internal protocol TwitterClientTestSuite {}

extension TwitterClientTestSuite {
    /// Helper function to create and manage a test application instance
    /// Creates a test application, configures the database, runs the provided test closure, and ensures proper cleanup
    ///
    /// - Parameter test: The test closure to execute with the application instance
    /// - Throws: Any errors that occur during test execution, including:
    ///   - Application initialization errors
    ///   - Database configuration errors
    ///   - Test execution errors
    ///   - Shutdown errors
    public func withApp(test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try await app.autoRevert()
            try await DatabaseConfigurator(app: app).configureDatabases()
            try await DatabaseSeeder(app: app).seed()
            try await test(app)
        } catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
}
