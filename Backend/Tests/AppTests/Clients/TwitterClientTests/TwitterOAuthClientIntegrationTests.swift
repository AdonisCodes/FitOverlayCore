// TwitterOAuthClientIntegrationTests.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

@testable import App
import Testing
import VaporTesting

/// Test suite for Twitter OAuth functionality
/// These tests verify the ability to request tokens and generate authentication URLs
extension SerialDbTestSuites {
    @Suite("TwitterOAuthClientIntegrationTests")
    internal struct TwitterOAuthClientIntegrationTests: TwitterClientTestSuite {
        /// Tests the ability to request an OAuth token
        /// Verifies that the token and token secret are properly generated and contain valid values
        ///
        /// - Throws: Any errors that occur during test execution, including:
        ///   - Client initialization errors
        ///   - Token request failures
        @Test("Test Request Token")
        public func requestToken() async throws {
            try await withApp { app in
                // Initialize the Twitter client
                let twitterClient = try TwitterClient(logger: app.logger, client: app.client, database: app.db)
                // Request an OAuth token
                let token = try await twitterClient.auth.requestToken()

                // Ensure the token and token secret have valid lengths
                #expect(token.oauthToken.count > 5, "OAuth token should have more than 5 characters")
                #expect(token.oauthTokenSecret.count > 5, "OAuth token secret should have more than 5 characters")
            }
        }

        /// Tests the ability to generate an authentication URL
        /// Verifies that the generated URL matches the expected format
        ///
        /// - Throws: Any errors that occur during test execution, including:
        ///   - Client initialization errors
        ///   - URL generation failures
        @Test("Make Authenticate URL")
        public func makeAuthenticateURL() async throws {
            try await withApp { app in
                // Initialize the Twitter client
                let twitterClient = try TwitterClient(logger: app.logger, client: app.client, database: app.db)
                // Request an OAuth token
                let token = try await twitterClient.auth.requestToken()
                // Ensure the token and token secret are not empty
                #expect(token.oauthToken != "", "OAuth token should not be empty")
                #expect(token.oauthTokenSecret != "", "OAuth token secret should not be empty")

                // Generate the authentication URL using the token
                let url = try twitterClient.auth.makeAuthenticateURL(tokenObject: token)
                let expected = "https://api.twitter.com/oauth/authorize?oauth_token=\(token.oauthToken)"

                // Ensure the generated URL matches the expected format
                #expect(url.absoluteString == expected, "URL should match expected URL")
            }
        }
    }
}
