// TwitterUserToken.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

/// Model representing a Twitter user token.
public final class TwitterUserToken: Model, @unchecked Sendable {
    public static let schema = "Twitter-User-Token"

    /// Unique identifier for the Twitter user token.
    @ID(key: .id)
    public var id: UUID?

    /// The access token for the Twitter user.
    @Field(key: "access_token")
    public var accessToken: String

    /// The OAuth verifier for the Twitter user.
    @Field(key: "oauth_verifier")
    public var oauthVerifier: String

    /// The secret access token for the Twitter user.
    @Field(key: "secret_access_token")
    public var secretAccessToken: String

    /// The OAuth token associated with the Twitter user token.
    @OptionalParent(key: "oauth_token_id")
    public var oauthToken: TwitterOAuthToken?

    /// Timestamp when the Twitter user token was created.
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?

    /// Timestamp when the Twitter user token was last updated.
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?

    /// Timestamp when the Twitter user token was deleted.
    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?

    /// Initializes a new instance of `TwitterUserToken`.
    public init() {}

    /// Initializes a new instance of `TwitterUserToken` with the provided parameters.
    /// - Parameters:
    ///   - id: Unique identifier for the Twitter user token.
    ///   - accessToken: The access token for the Twitter user.
    ///   - secretAccessToken: The secret access token for the Twitter user.
    ///   - oauthVerifier: The OAuth verifier for the Twitter user.
    ///   - oauthTokenID: The OAuth token ID associated with the Twitter user token.
    ///   - createdAt: Timestamp when the Twitter user token was created.
    ///   - updatedAt: Timestamp when the Twitter user token was last updated.
    ///   - deletedAt: Timestamp when the Twitter user token was deleted.
    public init(
        id: UUID? = nil,
        accessToken: String,
        secretAccessToken: String,
        oauthVerifier: String,
        oauthTokenID: UUID? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.accessToken = accessToken
        self.secretAccessToken = secretAccessToken
        self.oauthVerifier = oauthVerifier
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        $oauthToken.id = oauthTokenID
    }

    /// Converts the model to a `TwitterUserTokenDTO`.
    /// - Returns: An instance of `TwitterUserTokenDTO`.
    public func toDTO() -> TwitterUserTokenDTO {
        .init(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            accessToken: accessToken,
            secretAccessToken: secretAccessToken,
            oauthVerifier: oauthVerifier,
            oauthTokenID: $oauthToken.id
        )
    }

    deinit {
        return
    }
}
