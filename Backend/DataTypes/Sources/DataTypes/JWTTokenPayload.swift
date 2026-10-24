// JWTTokenPayload.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Foundation
import JWT

/// Token subject type used in JWT authentication
/// - access: Represents an access token for short-term authentication
/// - refresh: Represents a refresh token for obtaining new access tokens
public enum JWTTokenSubject: String, Codable, Sendable {
    /// Short-term token used for API access
    case access
    /// Long-term token used to refresh access tokens
    case refresh
}

/// Data structure representing the payload of a JWT token used for user authentication
/// Conforms to JWTPayload protocol for JWT encoding/decoding functionality
public struct JWTTokenPayload: JWTPayload {
    /// Coding keys for JSON encoding/decoding of payload fields
    /// Maps internal property names to JWT standard claim names
    private enum CodingKeys: String, CodingKey {
        /// Maps 'subject' to 'sub' in JWT
        case subject = "sub"
        /// Maps 'expiration' to 'exp' in JWT
        case expiration = "exp"
        /// Maps 'userId' to 'uid' in JWT
        case userId = "uid"
        /// Maps 'tokenId' to 'tid' in JWT
        case tokenId = "tid"
    }

    /// The type of token (access or refresh)
    public var subject: JWTTokenSubject

    /// Claim containing the token's expiration timestamp
    public var expiration: ExpirationClaim

    /// Unique identifier of the user this token belongs to
    public var userId: String

    /// Unique identifier for this specific token instance
    public let tokenId: UUID

    /// Verifies the validity of the token
    /// - Parameter _: The JWT algorithm used for verification (unused in this implementation)
    /// - Throws: An error if the token has expired
    public func verify(using _: some JWTAlgorithm) throws {
        // Verify that the token hasn't expired
        try expiration.verifyNotExpired()
    }

    /// Creates a new JWT token payload
    /// - Parameters:
    ///   - subject: The type of token (access or refresh)
    ///   - expiration: The expiration time for the token
    ///   - userId: The ID of the user this token belongs to
    ///   - tokenId: Unique identifier for this specific token
    public init(
        subject: JWTTokenSubject,
        expiration: ExpirationClaim,
        userId: String,
        tokenId: UUID
    ) {
        self.subject = subject
        self.expiration = expiration
        self.userId = userId
        self.tokenId = tokenId
    }
}
