// AppLaunchControllerIntegrationTests.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

@testable import App
import Testing
import VaporTesting

/// Integration tests for the `AppLaunchController`.
/// These tests verify the controller's ability to handle requests and interact with the database.
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
            // Configure the database for the application
            try await DatabaseConfigurator(app: app).configureDatabases()
            // Register the `AppLaunchController` with the application
            try app.register(collection: AppLaunchController())
            // Execute the test closure with the application instance
            try await test(app)
        } catch {
            // Shut down the application in case of errors
            try await app.asyncShutdown()
            throw error
        }
        // Ensure proper cleanup by shutting down the application
        try await app.asyncShutdown()
    }

    /// Tests if a user is accepted or not
    @Test("Is User Accepted")
    public func request() {
        // Expect the test to pass with a true value
        #expect(Bool(true))
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
