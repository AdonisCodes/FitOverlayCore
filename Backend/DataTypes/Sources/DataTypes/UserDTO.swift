// UserDTO.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

/// A data transfer object representing a user in the system.
/// This struct conforms to Vapor's Content protocol for HTTP encoding/decoding.
public struct UserDTO: Content {
    /// The unique identifier for the user.
    public var id: UUID?

    /// The timestamp when the user record was created.
    public var createdAt: Date?

    /// The timestamp when the user record was last updated.
    public var updatedAt: Date?

    /// The timestamp when the user record was soft deleted, if applicable.
    public var deletedAt: Date?

    /// The user's chosen username.
    public var username: String

    /// The user's phone number for contact and verification purposes.
    public var phoneNumber: String

    /// The user's Instagram handle, if provided.
    public var instagramHandle: String?

    /// The storage key for the user's profile picture.
    public var profilePictureKey: String?

    /// The URL where the user's profile picture can be accessed.
    public var profilePictureUrl: String?

    /// Indicates whether the user has been accepted into the system.
    public var accepted: Bool

    /// Initializes a new UserDTO instance.
    /// - Parameters:
    ///   - id: The unique identifier for the user
    ///   - createdAt: The timestamp when the user record was created
    ///   - updatedAt: The timestamp when the user record was last updated
    ///   - deletedAt: The timestamp when the user record was soft deleted
    ///   - username: The user's chosen username
    ///   - phoneNumber: The user's phone number
    ///   - instagramHandle: The user's Instagram handle (optional)
    ///   - profilePictureKey: The storage key for the user's profile picture (optional)
    ///   - profilePictureUrl: The URL for accessing the user's profile picture (optional)
    ///   - accepted: Whether the user has been accepted into the system
    public init(
        id: UUID? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil,
        username: String,
        phoneNumber: String,
        instagramHandle: String? = nil,
        profilePictureKey: String? = nil,
        profilePictureUrl: String? = nil,
        accepted: Bool
    ) {
        // Assign all provided values to their corresponding properties
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.username = username
        self.phoneNumber = phoneNumber
        self.instagramHandle = instagramHandle
        self.profilePictureKey = profilePictureKey
        self.profilePictureUrl = profilePictureUrl
        self.accepted = accepted
    }
}
