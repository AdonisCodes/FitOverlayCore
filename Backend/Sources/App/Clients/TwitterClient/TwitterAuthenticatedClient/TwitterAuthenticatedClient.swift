// TwitterAuthenticatedClient.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent
import TwitterAPIKit
import Vapor

/// A client for making authenticated requests to the Twitter API.
/// This client handles posting tweets and other authenticated operations
/// using a valid Twitter API access token.
internal struct TwitterAuthenticatedClient: TwitterClientBase {
    /// Logger instance for tracking operations
    public let logger: Logger

    /// HTTP client for making requests
    public let client: Client

    /// Database instance for data persistence
    public let database: Database

    /// Twitter API client instance configured with authentication
    public let twitterClient: TwitterAPISession

    /// Posts a new tweet to Twitter with the given message.
    ///
    /// This method sends a tweet to Twitter using the authenticated API client.
    /// It logs the operation and handles any errors that occur during the request.
    ///
    /// - Parameter message: The text content of the tweet to post.
    /// - Returns: A `TwitterPostResponse` containing the posted tweet details.
    /// - Throws: `TwitterAuthenticatedClientError` if the request fails or returns invalid data.
    public func postTweet(message: String) async throws -> PostTweetsRequestV2.Response {
        // Start the backend metric for posting a tweet
        BackendMetric.twitterPostTweet(status: .start).increment()

        // Send the tweet using the Twitter API client
        let request = PostTweetsRequestV2(text: message)
        do {
            return try await twitterClient.send(request)
        } catch let error as TwitterAPIError {
            let message = "Failed to Post Tweet"
            logger.error(
                .init(stringLiteral: message),
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string(String(reflecting: error)),
                ]
            )
            BackendMetric.twitterPostTweet(status: .fail).increment()
            throw TwitterAuthenticatedClientError.twitterAPIResponseError(error)
        } catch let error as TwitterAPIKitError {
            let message = "Failed to Post Tweet"
            logger.error(
                .init(stringLiteral: message),
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string(String(reflecting: error)),
                ]
            )
            BackendMetric.twitterPostTweet(status: .fail).increment()
            throw TwitterOAuthClientError.twitterAPIKitResponseError(error)
        }
    }
}
