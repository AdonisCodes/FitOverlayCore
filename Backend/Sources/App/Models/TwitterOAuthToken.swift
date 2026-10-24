// TwitterOAuthToken.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

public final class TwitterOAuthToken: Model, @unchecked Sendable {
    public static let schema = "Twitter-O-Auth-Token"

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "oauth_token")
    public var oauthToken: String

    @Field(key: "oauth_token_secret")
    public var oauthTokenSecret: String

    @OptionalBoolean(key: "oauth_callback_confirmed")
    public var oauthCallbackConfirmed: Bool?

    @OptionalParent(key: "user_id")
    public var user: UserModel?

    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?

    public init() {}

    public init(
        id: UUID? = nil,
        oauthToken: String,
        oauthTokenSecret: String,
        oauthCallbackConfirmed: Bool? = nil,
        userID: UUID? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.oauthToken = oauthToken
        self.oauthTokenSecret = oauthTokenSecret
        self.oauthCallbackConfirmed = oauthCallbackConfirmed
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        $user.id = userID
    }

    deinit {
        return
    }
}
