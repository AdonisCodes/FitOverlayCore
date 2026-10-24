// FitOverlayWebCoreClientIntegrationTests.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

@testable import App
import Testing
import VaporTesting

@Suite("FitOverlayWebCoreClientIntegrationTests")
internal struct FitOverlayWebCoreClientIntegrationTests: MinimalVaporApplicationTestSuite {
    /// Tests that getting the HTML of a website using `FitOverlayWebCoreClient` is a success
    ///
    /// - Throws: Any errors that occur during the test execution, including:
    ///   - Client initialization errors
    ///   - Network errors
    @Test("Get Website HTML Success")
    public func getWebsiteHTMLSuccess() async throws {
        try await withApp { app in
            let response = try await FitOverlayWebCoreClient(client: app.client)
                .getWebsiteHTML(
                    payload: .init(
                        url: URL.fromString(
                            payload: .init(
                                string: "https://williamferns.org"
                            )
                        )
                    )
                )
            #expect(response.count > 100)
        }
    }
}
