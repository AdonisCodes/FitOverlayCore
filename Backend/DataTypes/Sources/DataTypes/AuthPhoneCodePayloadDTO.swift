// AuthPhoneCodePayloadDTO.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

/// A data transfer object (DTO) representing authentication payload containing a phone number and verification code.
/// Conforms to Vapor's Content protocol for HTTP message encoding and decoding.
public struct AuthPhoneCodePayloadDTO: Content {
    /// The validated phone number string.
    public let phoneNumber: String

    /// The verification code string sent to the phone number.
    public let code: String

    /// Initializes a new authentication phone code payload.
    /// - Parameters:
    ///   - phoneNumber: The raw phone number string to be validated
    ///   - code: The verification code string
    /// - Throws: An error if phone number validation fails
    public init(phoneNumber: String, code: String) throws {
        // Validate and normalize the phone number using PhoneNumberPayloadDTO
        self.phoneNumber = try PhoneNumberPayloadDTO(
            number: phoneNumber
        ).phoneNumber
        self.code = code
    }
}
