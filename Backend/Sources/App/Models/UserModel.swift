// UserModel.swift
// Copyright (c) 2025 FitOverlay
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

    /// The Instagram handle of the user.
    @OptionalField(key: "instagram_handle")
    public var instagramHandle: String?

    /// The profile picture key of the user.
    @OptionalField(key: "profile_picture_key")
    public var profilePictureKey: String?

    /// Timestamp when the user was created.
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?

    /// Timestamp when the user was last updated.
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?

    /// Timestamp when the user was deleted.
    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?

    /// Indicates if the users application was accepted
    @Field(key: "accepted")
    public var accepted: Bool

    /// Initializes a new instance of `UserModel`.
    public init() {}

    /// Initializes a new instance of `UserModel` with the provided parameters.
    /// - Parameters:
    ///   - id: Unique identifier for the user.
    ///   - username: The username of the user.
    ///   - phoneNumber: The phone number of the user.
    ///   - instagramHandle: The Instagram handle of the user.
    ///   - profilePictureKey: The profile picture key of the user.
    ///   - createdAt: Timestamp when the user was created.
    ///   - updatedAt: Timestamp when the user was last updated.
    ///   - deletedAt: Timestamp when the user was deleted.
    ///   - accepted: Indicates if the user is accepted into FitOverlay. Defaults to false
    public init(
        id: UUID? = nil,
        username: String,
        phoneNumber: String,
        instagramHandle: String? = nil,
        profilePictureKey: String? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil,
        accepted: Bool = false
    ) {
        self.id = id
        self.username = username
        self.phoneNumber = phoneNumber
        self.instagramHandle = instagramHandle
        self.profilePictureKey = profilePictureKey
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.accepted = accepted
    }

    /// Converts the model to a `UserDTO`.
    /// - Returns: An instance of `UserDTO`.
    public func toDTO(logger: Logger) throws -> UserDTO {
        let profilePictureUrl: String? = if let profilePictureKey {
            try TigrisService(logger: logger).getTigrisUrl(profilePictureKey)
        } else {
            nil
        }

        return .init(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            username: username,
            phoneNumber: phoneNumber,
            instagramHandle: instagramHandle,
            profilePictureKey: profilePictureKey,
            profilePictureUrl: profilePictureUrl,
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
            instagramHandle: dto.instagramHandle,
            profilePictureKey: dto.profilePictureKey,
            accepted: dto.accepted
        )
    }

    deinit {
        return
    }
}
