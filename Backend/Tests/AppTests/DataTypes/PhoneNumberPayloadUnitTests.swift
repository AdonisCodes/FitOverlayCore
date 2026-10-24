// PhoneNumberPayloadUnitTests.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import DataTypes
import Testing

/// Unit tests for `PhoneNumberPayloadDTO` (PhoneNumberKit-backed E.164 normalization).
@Suite("PhoneNumberPayloadUnitTests")
internal struct PhoneNumberPayloadUnitTests {
    /// Valid international numbers should normalize to bare E.164.
    @Test("Valid numbers normalize to E.164")
    public func validNumbers() throws {
        #expect(try PhoneNumberPayloadDTO(number: "+27 82 123 4567").phoneNumber == "+27821234567")
        #expect(try PhoneNumberPayloadDTO(number: "+1 (415) 555-2671").phoneNumber == "+14155552671")
        #expect(try PhoneNumberPayloadDTO(number: "+44 7911 123456").phoneNumber == "+447911123456")
    }

    /// Garbage input should be rejected with `invalidPhoneNumber`.
    @Test("Invalid numbers throw")
    public func invalidNumbers() {
        #expect(throws: GenericErrors.invalidPhoneNumber) {
            _ = try PhoneNumberPayloadDTO(number: "not-a-number")
        }
        #expect(throws: GenericErrors.invalidPhoneNumber) {
            _ = try PhoneNumberPayloadDTO(number: "")
        }
    }
}
