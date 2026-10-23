// PhoneNumberPayloadUnitTests.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import DataTypes
import Testing

/// Unit tests for `PhoneNumberPayloadDTO` E.164 normalization.
@Suite("PhoneNumberPayloadUnitTests")
internal struct PhoneNumberPayloadUnitTests {
    /// Valid international numbers should normalize to bare E.164.
    @Test("Valid numbers normalize to E.164")
    public func validNumbers() throws {
        #expect(try PhoneNumberPayloadDTO(number: "+27 82 123 4567").phoneNumber == "+27821234567")
        #expect(try PhoneNumberPayloadDTO(number: "+1 (415) 555-2671").phoneNumber == "+14155552671")
        #expect(try PhoneNumberPayloadDTO(number: "0044 7911 123456").phoneNumber == "+447911123456")
    }

    /// Numbers without a country prefix or with garbage should be rejected.
    @Test("Invalid numbers throw")
    public func invalidNumbers() {
        #expect(throws: GenericErrors.invalidPhoneNumber) {
            _ = try PhoneNumberPayloadDTO(number: "0821234567")
        }
        #expect(throws: GenericErrors.invalidPhoneNumber) {
            _ = try PhoneNumberPayloadDTO(number: "+1-800-FLOWERS")
        }
        #expect(throws: GenericErrors.invalidPhoneNumber) {
            _ = try PhoneNumberPayloadDTO(number: "")
        }
        #expect(throws: GenericErrors.invalidPhoneNumber) {
            _ = try PhoneNumberPayloadDTO(number: "+123")
        }
    }
}
