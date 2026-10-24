// MinimalVaporApplicationTestSuite.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

internal protocol MinimalVaporApplicationTestSuite {}

extension MinimalVaporApplicationTestSuite {
    /// Helper function to create and manage a test application instance
    /// Creates a test application, runs the provided test closure, and ensures proper cleanup
    ///
    /// - Parameter test: The test closure to execute with the application instance
    /// - Throws: Any errors that occur during test execution, including:
    ///   - Application initialization errors
    ///   - Test execution errors
    ///   - Shutdown errors
    public func withApp(test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try await test(app)
        } catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
}
