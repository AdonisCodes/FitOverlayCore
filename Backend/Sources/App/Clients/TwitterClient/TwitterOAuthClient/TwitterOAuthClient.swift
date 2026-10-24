// TwitterOAuthClient.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent
import Foundation
import TwitterAPIKit
import Vapor

/// A client for handling Twitter OAuth 1.0a authentication flow.
/// This client manages the OAuth token request, authentication URL generation,
/// and conversion of OAuth tokens to user access tokens.
internal struct TwitterOAuthClient: TwitterClientBase {
    /// Logger instance for tracking operations
    public let logger: Logger

    /// HTTP client for making requests
    public let client: Client

    /// Database instance for token storage
    public let database: Database

    /// Twitter API client instance
    public let twitterClient: TwitterAPISession

    /// OAuth callback URL for the authentication flow
    public var callbackURL: URL

    /// Initializes a new TwitterOAuthClient.
    /// - Parameters:
    ///   - logger: Logger instance for tracking operations
    ///   - client: HTTP client for making requests
    ///   - database: Database instance for token storage
    ///   - twitterClient: Twitter API client instance
    ///   - callbackURL: OAuth callback URL for the authentication flow
    public init(
        logger: Logger,
        client: Client,
        database: Database,
        twitterClient: TwitterAPISession,
        callbackURL: URL
    ) {
        self.logger = logger
        self.client = client
        self.database = database
        self.twitterClient = twitterClient
        self.callbackURL = callbackURL
    }

    /// Requests a new OAuth token from Twitter.
    ///
    /// This method initiates the OAuth token request process with Twitter,
    /// and returns a `TwitterOAuthToken` if successful.
    ///
    /// - Returns: A `TwitterOAuthToken` instance if successful.
    /// - Throws: `TwitterOAuthClientError` if the request fails.
    public func requestToken() async throws -> TwitterOAuthToken {
        BackendMetric.twitterOAuthRequest(status: .start).increment()
        let oauthApi = OAuth10aAPI(session: twitterClient)
        let request = PostOAuthRequestTokenRequestV1(
            oauthCallback: callbackURL.absoluteString
        )
        do {
            let response = try await oauthApi.postOAuthRequestToken(request)
            let savedToken = try await saveOAuthToken(tokenObject: response)
            BackendMetric.twitterOAuthRequest(status: .success).increment()
            return savedToken
        } catch let error as TwitterAPIError {
            logger.error(
                "Failed to obtain request token.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string(String(reflecting: error)),
                ]
            )
            BackendMetric.twitterOAuthRequest(status: .fail).increment()
            throw TwitterOAuthClientError.twitterAPIResponseError(error)
        } catch let error as TwitterAPIKitError {
            logger.error(
                "Failed to obtain request token.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string(String(reflecting: error)),
                ]
            )
            BackendMetric.twitterOAuthRequest(status: .fail).increment()
            throw TwitterOAuthClientError.twitterAPIKitResponseError(error)
        }
    }

    /// Generates the authentication URL for the user to authorize the application.
    ///
    /// This method constructs the URL that the user should visit to authorize the application
    /// using the provided OAuth token.
    ///
    /// - Parameter tokenObject: The OAuth token object obtained from `requestToken()`.
    /// - Returns: URL that the user should visit to authorize the application.
    /// - Throws: `TwitterOAuthClientError` if URL generation fails.
    public func makeAuthenticateURL(tokenObject: TwitterOAuthToken) throws -> URL {
        let oauthApi = OAuth10aAPI(session: twitterClient)
        let oauthToken = tokenObject.oauthToken

        // Generate the authentication URL
        guard let authenticateURL = oauthApi.makeOAuthAuthorizeURL(
            .init(oauthToken: oauthToken)
        ) else {
            logger.error(
                "Failed to make authenticateURL.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "oauthToken": .string("\(oauthToken)"),
                ]
            )
            throw TwitterOAuthClientError.unableToMakeAuthenticateURL
        }

        logger.info(
            "Go to authenticate URL '\(authenticateURL)' and authenticate.",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "oauthToken": .string("\(oauthToken)"),
            ]
        )
        return authenticateURL
    }

    /// Converts OAuth tokens to user access tokens after successful authentication.
    ///
    /// This method exchanges the OAuth token and verifier for user access tokens.
    ///
    /// - Parameters:
    ///   - oauthToken: The OAuth token received from Twitter.
    ///   - oauthVerifier: The verification code received after user authorization.
    /// - Returns: `TwitterUserToken` containing access tokens.
    /// - Throws: `TwitterOAuthClientError` if token conversion fails.
    public func getUserTokens(oauthToken: String, oauthVerifier: String) async throws -> TwitterUserToken {
        // Retrieve the OAuth token object from the database
        guard let oauthTokenObject = try await getOAuthTokenObject(fromOAuthToken: oauthToken) else {
            throw TwitterOAuthClientError.invalidOAuthToken
        }

        // Convert the OAuth token to user access tokens
        let userTokens = try await convertOAuthTokenToUserTokens(
            tokenObject: oauthTokenObject,
            oauthVerifier: oauthVerifier
        )

        // Save the user tokens to the database
        return try await saveUserTokens(
            userTokens: userTokens,
            oauthTokenObject: oauthTokenObject,
            oauthVerifier: oauthVerifier
        )
    }

    /// Saves the user tokens to the database.
    ///
    /// This method persists the user tokens in the database for future use.
    ///
    /// - Parameters:
    ///   - userTokens: The tokens to be saved.
    ///   - oauthTokenObject: The original OAuth token.
    ///   - oauthVerifier: The verification code.
    /// - Returns: The saved `TwitterUserToken`.
    /// - Throws: Database errors if saving fails.
    private func saveUserTokens(
        userTokens: Self.TwitterUserTokens,
        oauthTokenObject: TwitterOAuthToken,
        oauthVerifier: String
    ) async throws -> TwitterUserToken {
        let userTokenModel = TwitterUserToken(
            accessToken: userTokens.accessToken,
            secretAccessToken: userTokens.secretAccessToken,
            oauthVerifier: oauthVerifier,
            oauthTokenID: oauthTokenObject.id
        )

        do {
            logger.info(
                "Saving Twitter user tokens to database.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "userTokenModel": .string(userTokenModel.description),
                ]
            )
            try await userTokenModel.save(on: database)
            return userTokenModel
        } catch {
            logger.error(
                "Failed to save requested Twitter user tokens to database.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "userTokens": .string(userTokenModel.description),
                    "error": .string(String(reflecting: error)),
                ]
            )
            throw TwitterOAuthClientError.failedToSaveToken(tokenType: .access, error: error)
        }
    }

    /// Saves an OAuth token to the database.
    ///
    /// This method persists the OAuth token in the database for future use.
    ///
    /// - Parameter tokenObject: The OAuth token to save.
    /// - Returns: The saved `TwitterOAuthToken`.
    /// - Throws: Database errors if saving fails.
    private func saveOAuthToken(tokenObject: TwitterOAuthTokenV1) async throws -> TwitterOAuthToken {
        let token = TwitterOAuthToken(
            oauthToken: tokenObject.oauthToken,
            oauthTokenSecret: tokenObject.oauthTokenSecret,
            oauthCallbackConfirmed: tokenObject.oauthCallbackConfirmed
        )
        do {
            logger.info(
                "Saving Twitter token to database.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "tokenObject": .string(String(reflecting: tokenObject)),
                ]
            )
            try await token.save(on: database)
        } catch {
            logger.error(
                "Failed to save requested Twitter token to database.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "tokenObject": .string(token.description),
                    "error": .string(String(reflecting: error)),
                ]
            )
            throw TwitterOAuthClientError.failedToSaveToken(tokenType: .oauth, error: error)
        }
        return token
    }

    /// Retrieves an OAuth token from the database.
    ///
    /// This method fetches an OAuth token from the database using the provided token string.
    ///
    /// - Parameter oauthToken: The token string to look up.
    /// - Returns: Optional `TwitterOAuthToken` if found.
    /// - Throws: Database errors if query fails.
    private func getOAuthTokenObject(fromOAuthToken oauthToken: String) async throws -> TwitterOAuthToken? {
        do {
            return try await TwitterOAuthToken
                .query(on: database)
                .filter(\.$oauthToken, .equal, oauthToken)
                .first()
        } catch {
            logger.error(
                "Failed to retrieve OAuth token from database.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "oauthToken": .string(oauthToken),
                    "error": .string(String(reflecting: error)),
                ]
            )
            throw TwitterOAuthClientError.failedToGetTokenFromDatabase(tokenType: .oauth, error: error)
        }
    }

    /// Converts an OAuth token to user access tokens.
    ///
    /// This method exchanges the OAuth token and verifier for user access tokens.
    ///
    /// - Parameters:
    ///   - tokenObject: The OAuth token to convert.
    ///   - oauthVerifier: The verification code from the OAuth process.
    /// - Returns: `TwitterUserTokens` containing access and secret tokens.
    /// - Throws: `TwitterOAuthClientError` if conversion fails.
    private func convertOAuthTokenToUserTokens(
        tokenObject: TwitterOAuthToken,
        oauthVerifier: String
    ) async throws -> Self.TwitterUserTokens {
        BackendMetric.twitterUserTokensConverted(status: .start).increment()

        let oauthApi = OAuth10aAPI(session: twitterClient)
        do {
            let token = try await oauthApi.postOAuthAccessToken(
                .init(
                    oauthToken: tokenObject.oauthToken,
                    oauthVerifier: oauthVerifier
                )
            )
            BackendMetric.twitterUserTokensConverted(status: .success).increment()
            return .init(accessToken: token.oauthToken, secretAccessToken: token.oauthTokenSecret)
        } catch let error as TwitterAPIError {
            let message = "Failed to convert oauth token to user token"
            logger.error(
                .init(stringLiteral: message),
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string(String(reflecting: error)),
                ]
            )
            BackendMetric.twitterUserTokensConverted(status: .fail).increment()
            throw TwitterOAuthClientError.twitterAPIResponseError(error)
        } catch let error as TwitterAPIKitError {
            let message = "Failed to convert oauth token to user token"
            logger.error(
                .init(stringLiteral: message),
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string(String(reflecting: error)),
                ]
            )
            BackendMetric.twitterUserTokensConverted(status: .fail).increment()
            throw TwitterOAuthClientError.twitterAPIKitResponseError(error)
        }
    }

    private func loginTwitterUser() throws {}

    /// A structure representing the user tokens required for Twitter OAuth authentication.
    ///
    /// This struct contains the access token and secret access token used for authenticating
    /// requests to the Twitter API.
    public struct TwitterUserTokens: Content {
        /// The access token used for Twitter API authentication.
        public let accessToken: String

        /// The secret access token used for Twitter API authentication.
        public let secretAccessToken: String
    }

    /// A structure representing the query parameters for Twitter OAuth redirection.
    ///
    /// This struct encapsulates the OAuth token and verifier returned by Twitter during
    /// the OAuth authentication process.
    public struct TwitterOAuthRedirectQueryParameters: Content {
        /// The OAuth token returned by Twitter.
        public let oauthToken: String

        /// The OAuth verifier returned by Twitter.
        public let oauthVerifier: String

        /// Coding keys to map the JSON keys to the struct properties.
        public enum CodingKeys: String, CodingKey {
            case oauthToken = "oauth_token"
            case oauthVerifier = "oauth_verifier"
        }
    }

    /// A structure representing the content of a tweet to be posted.
    ///
    /// This struct contains the message text of the tweet to be posted to Twitter.
    public struct PostTweetContent: Content {
        /// The text content of the tweet.
        public let message: String
    }
}
