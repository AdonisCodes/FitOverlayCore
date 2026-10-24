// AuthenticationCodeModel.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

/// Model representing an authentication code.
public final class AuthenticationCodeModel: Model, @unchecked Sendable {
    public static let schema = "Authentication-Code"

    /// Unique identifier for the authentication code.
    @ID(key: .id)
    public var id: UUID?

    /// The authentication code.
    @Field(key: "code")
    public var code: String

    /// The phone number associated with the authentication code.
    @Field(key: "phone_number")
    public var phoneNumber: String

    /// Timestamp when the authentication code was created.
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?

    /// Timestamp when the authentication code was last updated.
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?

    /// Timestamp when the authentication code was deleted.
    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?

    /// Initializes a new instance of `AuthenticationCodeModel`.
    public init() {}

    /// Initializes a new instance of `AuthenticationCodeModel` with the provided parameters.
    /// - Parameters:
    ///   - id: Unique identifier for the authentication code.
    ///   - code: The authentication code.
    ///   - phoneNumber: The phone number associated with the authentication code.
    ///   - createdAt: Timestamp when the authentication code was created.
    ///   - updatedAt: Timestamp when the authentication code was last updated.
    ///   - deletedAt: Timestamp when the authentication code was deleted.
    /// - Throws: Throws an error if the phone number is invalid.
    public init(
        id: UUID? = nil,
        code: String,
        phoneNumber: String,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) throws {
        self.id = id
        self.code = code
        self.phoneNumber = try PhoneNumberPayloadDTO(
            number: phoneNumber
        ).phoneNumber
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }

    /// Converts the model to a `AuthenticationCodeDTO`.
    /// - Returns: An instance of `AuthenticationCodeDTO`.
    /// - Throws: Throws an error if conversion fails.
    public func toDTO() throws -> AuthenticationCodeDTO {
        try AuthenticationCodeDTO(
            id: id,
            phoneNumber: phoneNumber,
            code: code,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt
        )
    }

    /// Creates an `AuthenticationCodeModel` from a `AuthenticationCodeDTO`.
    /// - Parameter dto: The `AuthenticationCodeDTO` to convert.
    /// - Returns: An instance of `AuthenticationCodeModel`.
    /// - Throws: Throws an error if conversion fails.
    public static func fromDTO(dto: AuthenticationCodeDTO) throws -> AuthenticationCodeModel {
        try AuthenticationCodeModel(
            id: dto.id,
            code: dto.code,
            phoneNumber: dto.phoneNumber,
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt,
            deletedAt: dto.deletedAt
        )
    }

    deinit {
        return
    }
}
