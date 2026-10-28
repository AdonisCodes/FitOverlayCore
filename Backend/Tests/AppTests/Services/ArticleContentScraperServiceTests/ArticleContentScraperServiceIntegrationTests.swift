// ArticleContentScraperServiceIntegrationTests.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

@testable import App
import Testing
import VaporTesting

@Suite("ArticleContentScraperServiceIntegrationTests")
internal struct ArticleContentScraperServiceIntegrationTests: MinimalVaporApplicationTestSuite {
    /// Tests that getting the HTML of a website using `FitOverlayWebCoreClient` is a success
    ///
    /// - Throws: Any errors that occur during the test execution, including:
    ///   - Client initialization errors
    ///   - Network errors
    @Test("Scrape Article Content Success")
    public func scrapeArticleContentSuccess() async throws {
        try await withApp { app in
            let article = try await ArticleContentScraperService(client: app.client, logger: app.logger)
                .scrapeArticle(payload: .init(
                    url: URL.fromString(
                        payload: .init(
                            string: "https://www.digitalocean.com/resources/articles/gpt-5-overview"
                        )
                    ),
                    scrollToBottom: true
                ))

            app.logger.info(
                "Article Inspection Log.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "article": .string(String(reflecting: article))
                ]
            )
        }
    }
}
