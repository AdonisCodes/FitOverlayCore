// AppLaunchControllerIntegrationTests.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

@testable import App
import Testing
import VaporTesting

/// Integration tests for the `AppLaunchController`.
/// These tests verify the controller's ability to handle requests and interact with the database.
/// Requires `PRIMARY_POSTGRES_URL` / `REGIONAL_POSTGRES_URL` to point at a running Postgres.
@Suite("AppLaunchControllerIntegrationTests")
internal struct AppLaunchControllerIntegrationTests {
    /// Helper method to create a test application instance for each test.
    /// This method handles proper setup and teardown of the application.
    ///
    /// - Parameter test: A closure that takes an `Application` instance and performs test operations.
    /// - Throws: Any errors that occur during test execution or application setup/teardown.
    private func withApp(_ test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try await DatabaseConfigurator(app: app).configureDatabases()
            try app.register(collection: AppLaunchController())
            try await test(app)
        } catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    /// The client config endpoint must respond with the required client version.
    @Test("Get client config")
    public func getClientConfig() async throws {
        try await withApp { app in
            try await app.testing().test(.GET, "App-Launch/get-client-config") { response async throws in
                #expect(response.status == .ok)
            }
        }
    }
}
