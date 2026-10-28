// TwitterOAuthClientError.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import TwitterAPIKit

/// Represents errors that can occur during Twitter OAuth authentication flow.
internal enum TwitterOAuthClientError: Error {
    /// Failed to get a token (oauth or user access tokens) from the database.
    case failedToGetTokenFromDatabase(tokenType: TwitterOAuthTokenType, error: Error)

    /// Failed to save a token (oauth or user access tokens) to the database.
    case failedToSaveToken(tokenType: TwitterOAuthTokenType, error: Error)

    /// The OAuth token is invalid or missing required data.
    case invalidOAuthToken

    /// Error returned from Twitter API request.
    case twitterAPIKitResponseError(TwitterAPIKitError)

    /// Error returned from Twitter API request
    case twitterAPIResponseError(TwitterAPIError)

    /// Failed to construct the Twitter authentication URL.
    case unableToMakeAuthenticateURL

    /// Unknown error occurred during OAuth process.
    case unknown(error: ErrorOrMessage)
}

/// Enum representing the type of Twitter OAuth tokens.
internal enum TwitterOAuthTokenType: String, Codable {
    /// The access tokens (access token and secret), can be retrieved by converting the oauth tokens to access tokens
    /// using the method `getUserTokens` in `TwitterOAuthClient`.
    case access

    /// The OAuth token, can be retrieved by calling `requestToken` method in `TwitterOAuthClient`.
    case oauth
}
