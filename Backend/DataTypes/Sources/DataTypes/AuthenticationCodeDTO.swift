// AuthenticationCodeDTO.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

/// A data transfer object representing an authentication code entity.
/// This struct is used to transfer authentication code data between different layers of the application.
/// Conforms to Vapor's Content protocol for HTTP message coding.
public struct AuthenticationCodeDTO: Content {
    /// The unique identifier for the authentication code.
    public var id: UUID?

    /// The actual authentication code string.
    public var code: String

    /// The phone number associated with this authentication code.
    public var phoneNumber: String

    /// The timestamp when this authentication code was created.
    public var createdAt: Date?

    /// The timestamp when this authentication code was last updated.
    public var updatedAt: Date?

    /// The timestamp when this authentication code was deleted (if applicable).
    public var deletedAt: Date?

    /// Initializes a new authentication code DTO.
    /// - Parameters:
    ///   - id: The unique identifier for the authentication code.
    ///   - phoneNumber: The phone number to associate with the authentication code.
    ///   - code: The authentication code string.
    ///   - createdAt: The creation timestamp.
    ///   - updatedAt: The last update timestamp.
    ///   - deletedAt: The deletion timestamp (if applicable).
    /// - Throws: An error if the phone number validation fails.
    public init(
        id: UUID?,
        phoneNumber: String,
        code: String,
        createdAt: Date?,
        updatedAt: Date?,
        deletedAt: Date?
    ) throws {
        // Assign the unique identifier
        self.id = id
        // Set the authentication code
        self.code = code
        // Validate and set the phone number using PhoneNumberPayloadDTO
        self.phoneNumber = try PhoneNumberPayloadDTO(
            number: phoneNumber
        ).phoneNumber
        // Set the timestamps
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}
