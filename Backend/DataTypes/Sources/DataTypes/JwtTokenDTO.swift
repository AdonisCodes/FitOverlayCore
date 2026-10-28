// JwtTokenDTO.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

/// A data transfer object representing a JWT (JSON Web Token) token.
/// This struct is used to transfer token-related data between different layers of the application.
/// Conforms to Vapor's Content protocol for easy encoding/decoding in HTTP requests/responses.
public struct JwtTokenDTO: Content {
    /// The unique identifier for the token record
    public var id: UUID?

    /// The actual JWT token string
    public var token: String

    /// The unique identifier of the user this token belongs to
    public var userId: UUID

    /// The subject/purpose of the JWT token
    public var subject: JWTTokenSubject

    /// Timestamp indicating when the token was created
    public var createdAt: Date?

    /// Timestamp indicating when the token was last updated
    public var updatedAt: Date?

    /// Timestamp indicating when the token was deleted (for soft delete functionality)
    public var deletedAt: Date?

    /// Initializes a new JWT token DTO
    /// - Parameters:
    ///   - id: Optional unique identifier for the token record
    ///   - token: The JWT token string
    ///   - userId: The ID of the user this token belongs to
    ///   - subject: The subject/purpose of the token
    ///   - createdAt: Optional timestamp of token creation
    ///   - updatedAt: Optional timestamp of last token update
    ///   - deletedAt: Optional timestamp of token deletion
    public init(
        id: UUID? = nil,
        token: String,
        userId: UUID,
        subject: JWTTokenSubject,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        // Assign all parameters to their corresponding properties
        self.id = id
        self.token = token
        self.userId = userId
        self.subject = subject
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}
