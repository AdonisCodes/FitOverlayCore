// PhoneNumberPayloadDTO.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import PhoneNumberKit
import Vapor

/// A data transfer object (DTO) that represents a phone number payload.
/// This struct conforms to Vapor's Content protocol for HTTP encoding/decoding.
public struct PhoneNumberPayloadDTO: Content {
    /// The phone number string in E.164 format.
    /// E.164 is the international standard format for phone numbers.
    public let phoneNumber: String

    /// Initializes a new PhoneNumberPayloadDTO with a given phone number string.
    /// The phone number is parsed and formatted to E.164 format during initialization.
    ///
    /// - Parameter number: The phone number string to be parsed and formatted
    /// - Throws: GenericErrors.invalidPhoneNumber if the phone number is invalid or cannot be parsed
    public init(number: String) throws {
        // Create a utility instance for phone number operations
        let phoneNumberUtility = PhoneNumberUtility()

        do {
            // Parse the input number string into a phone number object
            let phoneNumberParsed = try phoneNumberUtility.parse(number)
            // Format the parsed phone number to E.164 format
            phoneNumber = phoneNumberUtility.format(phoneNumberParsed, toType: .e164)
        } catch {
            // If parsing fails, throw an invalid phone number error
            throw GenericErrors.invalidPhoneNumber
        }
    }

    /// Decoder initializer required for Vapor's Content protocol.
    /// Decodes a phone number from JSON or other encoded formats.
    ///
    /// - Parameter decoder: The decoder to read data from
    /// - Throws: DecodingError if decoding fails
    /// - Throws: GenericErrors.invalidPhoneNumber if the phone number is invalid
    public init(from decoder: any Decoder) throws {
        // Extract the container using coding keys
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Decode the phone number string
        let phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        // Initialize using the primary initializer
        try self.init(number: phoneNumber)
    }
}
