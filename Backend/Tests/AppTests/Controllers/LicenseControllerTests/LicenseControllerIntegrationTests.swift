// LicenseControllerIntegrationTests.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

@testable import App
import DataTypes
import Testing
import VaporTesting

/// Integration tests for the `LicenseController`.
/// Requires `PRIMARY_POSTGRES_URL` / `REGIONAL_POSTGRES_URL` to point at a running Postgres.
@Suite("LicenseControllerIntegrationTests")
internal struct LicenseControllerIntegrationTests {
    /// Helper method to create a test application instance for each test.
    private func withApp(_ test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try await DatabaseConfigurator(app: app).configureDatabases()
            try app.register(collection: LicenseController())
            try await test(app)
        } catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    /// A purchase webhook should create a licence, which can then be activated on a device.
    @Test("Purchase then activate device")
    public func purchaseThenActivate() async throws {
        try await withApp { app in
            var licenseKey: String?

            // 1. Simulate a (stubbed) Stripe purchase webhook.
            try await app.testing().test(
                .POST, "License/webhooks/stripe",
                beforeRequest: { request in
                    try request.content.encode(
                        PurchaseWebhookEventDTO(
                            provider: .stripe,
                            eventType: "checkout.session.completed",
                            plan: .lifetime,
                            customerEmail: "athlete@example.com",
                            providerTransactionId: "cs_test_123"
                        )
                    )
                },
                afterResponse: { response async throws in
                    #expect(response.status == .ok)
                    let payload = try response.content.decode(PurchaseWebhookResponseDTO.self)
                    #expect(payload.received)
                    licenseKey = payload.licenseKey
                }
            )

            let key = try #require(licenseKey)

            // 2. Activate a device against the new licence.
            try await app.testing().test(
                .POST, "License/activate",
                beforeRequest: { request in
                    try request.content.encode(
                        LicenseActivationRequestDTO(
                            key: key,
                            deviceIdentifier: "test-device-1",
                            deviceName: "Test MacBook",
                            platform: .macOS
                        )
                    )
                },
                afterResponse: { response async throws in
                    #expect(response.status == .ok)
                    let status = try response.content.decode(LicenseStatusResponseDTO.self)
                    #expect(status.isDeviceActivated)
                    #expect(status.activations.count == 1)
                }
            )
        }
    }
}
