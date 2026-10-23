// PhoneNumberPayloadDTO.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

/// A data transfer object (DTO) that represents a phone number payload.
/// This struct conforms to Vapor's Content protocol for HTTP encoding/decoding.
///
/// Phone numbers are normalized to E.164 format (`+` followed by up to 15 digits).
/// Validation is implemented without platform-specific dependencies so the DTO can be
/// used on Linux (backend/CI) as well as Apple platforms. If stricter, region-aware
/// validation is needed on the client, it can be layered on top in the UI.
public struct PhoneNumberPayloadDTO: Content {
    /// The phone number string in E.164 format.
    /// E.164 is the international standard format for phone numbers.
    public let phoneNumber: String

    /// Initializes a new PhoneNumberPayloadDTO with a given phone number string.
    /// The phone number is stripped of formatting characters and validated against E.164.
    ///
    /// - Parameter number: The phone number string to be parsed and formatted
    /// - Throws: GenericErrors.invalidPhoneNumber if the phone number is invalid or cannot be parsed
    public init(number: String) throws {
        phoneNumber = try Self.normalizeToE164(number)
    }

    /// Decoder initializer required for Vapor's Content protocol.
    /// Decodes a phone number from JSON or other encoded formats.
    ///
    /// - Parameter decoder: The decoder to read data from
    /// - Throws: DecodingError if decoding fails
    /// - Throws: GenericErrors.invalidPhoneNumber if the phone number is invalid
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        try self.init(number: phoneNumber)
    }

    /// Normalizes a raw phone number string to E.164.
    /// - Parameter raw: The raw user-provided phone number (may contain spaces, dashes, parentheses).
    /// - Returns: The normalized `+<countrycode><number>` string.
    /// - Throws: GenericErrors.invalidPhoneNumber when the input cannot represent a valid E.164 number.
    private static func normalizeToE164(_ raw: String) throws -> String {
        let allowedSeparators = CharacterSet(charactersIn: " -().")
        var trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            throw GenericErrors.invalidPhoneNumber
        }

        var hasPlusPrefix = false
        if trimmed.hasPrefix("+") {
            hasPlusPrefix = true
            trimmed.removeFirst()
        } else if trimmed.hasPrefix("00") {
            // Accept the international 00 prefix as an alias for +
            hasPlusPrefix = true
            trimmed.removeFirst(2)
        }

        var digits = ""
        for scalar in trimmed.unicodeScalars {
            if CharacterSet.decimalDigits.contains(scalar) {
                digits.unicodeScalars.append(scalar)
            } else if allowedSeparators.contains(scalar) {
                continue
            } else {
                throw GenericErrors.invalidPhoneNumber
            }
        }

        // E.164: country code cannot start with 0; total length 8...15 digits.
        guard hasPlusPrefix, digits.count >= 8, digits.count <= 15, digits.first != "0" else {
            throw GenericErrors.invalidPhoneNumber
        }

        return "+\(digits)"
    }
}
