// RSSFeedReaderClientIntegrationTests.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

@testable import App
import Testing
import VaporTesting

/// Test suite for the `RSSFeedReaderClient` class.
/// These tests verify the client's ability to fetch and parse different types of feeds.
@Suite("RSSFeedReaderClientIntegrationTests")
internal struct RSSFeedReaderClientIntegrationTests {
    /// Helper method to create a test application instance for each test.
    /// This method handles proper setup and teardown of the application.
    ///
    /// - Parameter test: A closure that takes an `Application` instance and performs test operations.
    /// - Throws: Any errors that occur during test execution or application setup/teardown.
    private func withApp(test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try await test(app)
        } catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    /// Tests the client's ability to read and parse different types of feeds.
    ///
    /// This test verifies:
    /// - RSS feeds are properly parsed and contain valid items
    /// - Atom feeds are properly parsed and contain valid items
    /// - Invalid URLs or non-feed URLs return empty results
    ///
    /// - Parameters:
    ///   - url: The URL to test fetching from
    ///   - feedExists: Whether the URL is expected to contain a valid feed
    /// - Throws: Any errors that occur during test execution or feed parsing.
    @Test(
        "Get feed items when feed exists",
        arguments: [
            (URL(string: "https://news.ycombinator.com/rss"), true), // rss format
            (
                URL(
                    string: "https://sample-feeds.rowanmanning.com/examples/222780a7caac12b938dfe09cd7d138f9/feed.xml"
                ),
                true
            ), // atom feed
            (URL(string: "https://example.com"), false),
            (URL(string: "https://invalid-feed.com"), false),
        ]
    )
    public func getFeedItemsWhenFeedExists(url: URL?, feedExists: Bool) async throws {
        guard
            let url
        else {
            #expect(Bool(false), "URL is nil")
            return
        }
        try await withApp { app in
            let client = RSSFeedReaderClient(logger: app.logger)

            if !feedExists {
                // Expect an error when the feed does not exist
                try await #require(
                    throws: RSSFeedReaderClientError.self,
                    "Should throw error when feed does not exist"
                ) {
                    try await client.read(from: url)
                }
                return
            }

            // Read the feed from the URL
            let result = try await client.read(from: url)

            // Ensure the feed contains items
            try #require(!result.items.isEmpty, "Feed should have items")

            for item in result.items {
                // Ensure each item has a non-empty title
                #expect(!item.title.isEmpty, "Item title should not be empty")
            }
        }
    }
}
