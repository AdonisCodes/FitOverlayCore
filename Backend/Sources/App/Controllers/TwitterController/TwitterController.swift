// TwitterController.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent
import Vapor

/// Controller for handling Twitter-related routes.
internal struct TwitterController: RouteCollection {
    /// Registers routes for Twitter operations.
    /// - Parameter routes: The routes builder to register routes on.
    public func boot(routes: RoutesBuilder) throws {
        let twitterRoute = routes.grouped("Twitter")

        twitterRoute.get("redirect", use: redirect)
        twitterRoute.post("post", use: post)
    }

    /// Handles the redirect from Twitter OAuth.
    /// - Parameter req: The request containing OAuth query parameters.
    /// - Returns: A base64 encoded string of the user tokens DTO.
    /// - Throws: An error if token retrieval or encoding fails.
    @Sendable
    public func redirect(req: Request) async throws -> String {
        let twitterClient = try TwitterClient(logger: req.logger, client: req.client, database: req.db)
        let queryParameters = try req.query.decode(TwitterOAuthClient.TwitterOAuthRedirectQueryParameters.self)

        let userTokens = try await twitterClient.auth.getUserTokens(
            oauthToken: queryParameters.oauthToken,
            oauthVerifier: queryParameters.oauthVerifier
        )

        req.logger.info("User Access Token: \(userTokens.accessToken)")
        req.logger.info("User Refresh Token: \(userTokens.accessToken)")

        let dto = userTokens.toDTO()
        return try dto.encodeToData().base64EncodedString()
    }

    /// Posts a tweet using the authenticated Twitter client.
    /// - Parameter req: The request containing the tweet content.
    /// - Returns: HTTP status indicating the result of the operation.
    /// - Throws: An error if posting the tweet fails.
    @Sendable
    public func post(req: Request) async throws -> HTTPStatus {
        let token = try TwitterClient.getUserToken(req: req)

        let authenticatedClient = try TwitterClient(
            logger: req.logger,
            client: req.client,
            database: req.db
        ).authenticated(token: token)

        let content = try req.content.decode(TwitterOAuthClient.PostTweetContent.self)
        let response = try await authenticatedClient.postTweet(message: content.message)
        req.logger.info(
            "Tweet response",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "data": .string("\(response.data)"),
            ]
        )

        return .ok
    }
}
