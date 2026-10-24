// TwitterAuthenticatedClientIntegrationTests.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

@testable import App
import AutomaUtilities
import Fakery
import Fluent
import Testing
import VaporTesting

/// Test suite for the authenticated Twitter client functionality
/// These tests verify that operations requiring user authentication work correctly
internal extension SerialDbTestSuites {
    @Suite("TwitterAuthenticatedClientIntegrationTests")
    struct TwitterAuthenticatedClientIntegrationTests: TwitterClientTestSuite {
        /// Tests the ability to post a tweet using an authenticated Twitter client
        /// This test verifies that:
        /// - A valid Twitter user token can be retrieved from the database
        /// - An authenticated client can be created with the token
        /// - A tweet can be successfully posted
        /// - The posted tweet contains the expected message
        ///
        /// - Throws: Any errors that occur during test execution, including:
        ///   - Environment variable retrieval errors
        ///   - Database query errors
        ///   - Client initialization errors
        ///   - API request failures
        @Test("Post Tweet")
        public func postTweet() async throws {
            try await withApp { app in
                // Retrieve the test Twitter user token ID from the environment
                let testTwitterUserTokenID = try Environment.getOrThrow("TEST_TWITTER_USER_TOKEN_ID")
                guard
                    let twitterUserTokenID = UUID(uuidString: testTwitterUserTokenID)
                else {
                    // Ensure the token ID can be converted to a UUID
                    try #require(
                        Bool(false),
                        "Failed to convert test Twitter User Token ID of value '\(testTwitterUserTokenID)' to UUID."
                    )
                    return
                }

                var userTokenForTweetPost: TwitterUserToken
                do {
                    // Query the database for the Twitter user token
                    guard
                        let token = try await TwitterUserToken.query(on: app.db)
                        .filter(\.$id == twitterUserTokenID)
                        .first()
                    else {
                        // Ensure the token is found in the database
                        try #require(Bool(false), "Failed to find Twitter User Token.")
                        return
                    }
                    userTokenForTweetPost = token
                } catch {
                    app.logger.error(
                        "Failed to query twitter user token on database.",
                        metadata: [
                            "to": .string("\(String(describing: Self.self)).\(#function)"),
                            "error": .string(String(reflecting: error))
                        ]
                    )
                    throw error
                }

                // Create an authenticated Twitter client with the token
                let client = try TwitterClient(
                    logger: app.logger,
                    client: app.client,
                    database: app.db
                )
                .authenticated(token: userTokenForTweetPost.toDTO())

                // Generate a random message and post a tweet
                let message = Faker().lorem.paragraph()
                let response = try await client.postTweet(message: message)
                // Ensure the response contains the expected message
                #expect(response.data.text == message, "Tweet message should match")
            }
        }
    }
}
