// JwtTokenModel.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

/// Model representing a JWT token.
public final class JwtTokenModel: Model, @unchecked Sendable {
    public init() {}

    public static let schema = "Jwt-Token"

    /// Unique identifier for the JWT token.
    @ID(key: .id)
    public var id: UUID?

    /// The JWT token string.
    @Field(key: "token")
    public var token: String

    /// The user ID associated with the JWT token.
    @Field(key: "user_id")
    public var userId: UUID

    /// The subject of the JWT token.
    @Enum(key: "subject")
    public var subject: JWTTokenSubject

    /// Timestamp when the JWT token was created.
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?

    /// Timestamp when the JWT token was last updated.
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?

    /// Timestamp when the JWT token was deleted.
    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?

    /// Initializes a new instance of `JwtTokenMod` with the provided parameters.
    /// - Parameters:
    ///   - id: Unique identifier for the JWT token.
    ///   - token: The JWT token string.
    ///   - userId: The user ID associated with the JWT token.
    ///   - subject: The subject of the JWT token.
    ///   - createdAt: Timestamp when the JWT token was created.
    ///   - updatedAt: Timestamp when the JWT token was last updated.
    ///   - deletedAt: Timestamp when the JWT token was deleted.
    public init(
        id: UUID? = nil,
        token: String,
        userId: UUID,
        subject: JWTTokenSubject,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.token = token
        self.userId = userId
        self.subject = subject
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }

    /// Converts the model to a `JwtTokenDTO`.
    /// - Returns: An instance of `JwtTokenDTO`.
    public func toDTO() -> JwtTokenDTO {
        .init(
            id: id,
            token: token,
            userId: userId,
            subject: subject,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt
        )
    }

    /// Creates a `JwtTokenModel` from a `JwtTokenDTO`.
    /// - Parameter dto: The `JwtTokenDTO` to convert.
    /// - Returns: An instance of `JwtTokenModel`.
    public static func fromDTO(dto: JwtTokenDTO) -> JwtTokenModel {
        JwtTokenModel(
            id: dto.id,
            token: dto.token,
            userId: dto.userId,
            subject: dto.subject,
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt,
            deletedAt: dto.deletedAt
        )
    }

    deinit {
        return
    }
}
