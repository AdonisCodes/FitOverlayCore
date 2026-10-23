// UserModel.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

/// Model representing a user.
public final class UserModel: Model, @unchecked Sendable {
    public static let schema = "User"

    /// Unique identifier for the user.
    @ID(key: .id)
    public var id: UUID?

    /// The username of the user.
    @Field(key: "username")
    public var username: String

    /// The phone number of the user.
    @Field(key: "phone_number")
    public var phoneNumber: String

    /// Timestamp when the user was created.
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?

    /// Timestamp when the user was last updated.
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?

    /// Timestamp when the user was deleted.
    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?

    /// Indicates if the user's application was accepted
    @Field(key: "accepted")
    public var accepted: Bool

    /// Initializes a new instance of `UserModel`.
    public init() {}

    /// Initializes a new instance of `UserModel` with the provided parameters.
    /// - Parameters:
    ///   - id: Unique identifier for the user.
    ///   - username: The username of the user.
    ///   - phoneNumber: The phone number of the user.
    ///   - createdAt: Timestamp when the user was created.
    ///   - updatedAt: Timestamp when the user was last updated.
    ///   - deletedAt: Timestamp when the user was deleted.
    ///   - accepted: Indicates if the user is accepted into FitOverlay. Defaults to false
    public init(
        id: UUID? = nil,
        username: String,
        phoneNumber: String,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil,
        accepted: Bool = false
    ) {
        self.id = id
        self.username = username
        self.phoneNumber = phoneNumber
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.accepted = accepted
    }

    /// Converts the model to a `UserDTO`.
    /// - Returns: An instance of `UserDTO`.
    public func toDTO() -> UserDTO {
        .init(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            username: username,
            phoneNumber: phoneNumber,
            accepted: accepted
        )
    }

    /// Creates a `UserModel` from a `UserDTO`.
    /// - Parameter dto: The `UserDTO` to convert.
    /// - Returns: An instance of `UserModel`.
    public static func fromDTO(dto: UserDTO) -> UserModel {
        UserModel(
            id: dto.id,
            username: dto.username,
            phoneNumber: dto.phoneNumber,
            accepted: dto.accepted
        )
    }

    deinit {
        return
    }
}
