// AuthenticationTokensPayloadDTO.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

/// A data transfer object (DTO) that represents authentication tokens.
/// This struct is used to transfer access and refresh tokens between different parts of the application.
/// Conforms to Vapor's `Content` protocol for easy encoding and decoding in HTTP responses.
public struct AuthenticationTokensPayloadDTO: Content {
    /// The access token string used for authenticating requests.
    /// This token is typically short-lived and should be included in API request headers.
    public var accessToken: String

    /// The refresh token string used to obtain new access tokens.
    /// This token is typically long-lived and should be securely stored.
    public var refreshToken: String

    /// Initializes a new authentication tokens payload with the specified access and refresh tokens.
    /// - Parameters:
    ///   - accessToken: The access token to be used for authentication
    ///   - refreshToken: The refresh token to be used for obtaining new access tokens
    public init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
