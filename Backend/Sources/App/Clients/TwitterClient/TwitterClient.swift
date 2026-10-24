// TwitterClient.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import AutomaUtilities
import DataTypes
import Fluent
import Foundation
import TwitterAPIKit
import Vapor

/// A protocol defining the base requirements for a Twitter client.
internal protocol TwitterClientBase {
    /// Logger instance for tracking operations.
    var logger: Logger { get }

    /// HTTP client for making requests.
    var client: Client { get }

    /// Database instance for data persistence.
    var database: Database { get }

    /// Twitter API client instance.
    var twitterClient: TwitterAPISession { get }
}

/// A client for interacting with Twitter API, handling authentication and requests.
internal struct TwitterClient: TwitterClientBase {
    /// Logger instance for tracking operations.
    public let logger: Logger

    /// HTTP client for making requests.
    public let client: Client

    /// Database instance for data persistence.
    public let database: Database

    /// OAuth client for handling Twitter authentication.
    public let auth: TwitterOAuthClient

    /// Callback URL for OAuth authentication.
    public let callbackURL: URL

    /// Twitter API client instance.
    public let twitterClient: TwitterAPISession

    /// Consumer key for Twitter API.
    public let consumerKey: String

    /// Consumer secret for Twitter API.
    public let consumerSecret: String

    /// Initializes a new TwitterClient.
    /// - Parameters:
    ///   - logger: Logger instance for tracking operations.
    ///   - client: HTTP client for making requests.
    ///   - database: Database instance for data persistence.
    /// - Throws: An error if environment variables are missing or URL is invalid.
    public init(logger: Logger, client: Client, database: Database) throws {
        self.logger = logger
        self.client = client
        self.database = database

        consumerKey = try Environment.getOrThrow("TWITTER_API_APP_KEY")
        consumerSecret = try Environment.getOrThrow("TWITTER_API_APP_SECRET_KEY")
        guard
            let url = try URL(string: "\(Environment.getOrThrow("BACKEND_URL"))/Twitter/redirect")
        else {
            throw GenericErrors.invalidUrl
        }
        callbackURL = url

        twitterClient = .init(
            authenticationType:
            .oauth10a(
                consumerKey: consumerKey,
                consumerSecret: consumerSecret,
                oauthToken: nil,
                oauthTokenSecret: nil
            )
        )
        auth = TwitterOAuthClient(
            logger: logger,
            client: client,
            database: database,
            twitterClient: twitterClient,
            callbackURL: callbackURL
        )
    }

    /// Creates an authenticated Twitter client using the provided user token.
    /// - Parameter token: The user token containing access credentials.
    /// - Returns: An instance of `TwitterAuthenticatedClient`.
    public func authenticated(token: TwitterUserTokenDTO) -> TwitterAuthenticatedClient {
        .init(
            logger: logger,
            client: client,
            database: database,
            twitterClient: .init(
                authenticationType:
                .oauth10a(
                    consumerKey: consumerKey,
                    consumerSecret: consumerSecret,
                    oauthToken: token.accessToken,
                    oauthTokenSecret: token.secretAccessToken
                )
            )
        )
    }

    /// Retrieves the user token from the request headers.
    /// - Parameter req: The request containing the authorization header.
    /// - Returns: A `TwitterUserTokenDTO` decoded from the header.
    /// - Throws: An error if the token is missing or decoding fails.
    public static func getUserToken(req: Request) throws -> TwitterUserTokenDTO {
        guard
            let tokenBase64String = req.headers.first(name: "Authorization")
        else {
            throw Abort(.unauthorized)
        }
        let data = Data(base64Encoded: tokenBase64String)

        do {
            return try TwitterUserTokenDTO.decodeJSONFromData(data: data)
        } catch {
            req.logger.error(
                "Failed to decode token from authorization header.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string(error.localizedDescription),
                ]
            )
            throw Abort(.unauthorized)
        }
    }
}
