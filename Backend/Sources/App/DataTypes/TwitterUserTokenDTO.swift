// TwitterUserTokenDTO.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

public struct TwitterUserTokenDTO: Content {
    public var id: UUID?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?
    public var accessToken: String
    public var secretAccessToken: String
    public var oauthVerifier: String
    public var oauthTokenID: UUID?

    public init(
        id: UUID? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil,
        accessToken: String,
        secretAccessToken: String,
        oauthVerifier: String,
        oauthTokenID: UUID? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.accessToken = accessToken
        self.secretAccessToken = secretAccessToken
        self.oauthVerifier = oauthVerifier
        self.oauthTokenID = oauthTokenID
    }
}
