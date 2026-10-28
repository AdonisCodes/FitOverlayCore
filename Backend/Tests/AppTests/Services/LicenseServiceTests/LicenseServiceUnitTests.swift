// LicenseServiceUnitTests.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

@testable import App
import Testing

/// Unit tests for `LicenseService` key generation.
@Suite("LicenseServiceUnitTests")
internal struct LicenseServiceUnitTests {
    /// Licence keys must follow the `FITO-XXXX-XXXX-XXXX-XXXX` format.
    @Test("Licence key format")
    public func keyFormat() {
        let key = LicenseService.generateKey()
        let groups = key.split(separator: "-")

        #expect(groups.count == 5)
        #expect(groups[0] == "FITO")
        for group in groups.dropFirst() {
            #expect(group.count == 4)
        }
    }

    /// Licence keys must not contain ambiguous characters (0, O, 1, I).
    @Test("Licence key excludes ambiguous characters")
    public func keyExcludesAmbiguousCharacters() {
        for _ in 0 ..< 50 {
            let key = LicenseService.generateKey()
            let body = key.split(separator: "-").dropFirst().joined()
            #expect(!body.contains("0"))
            #expect(!body.contains("O"))
            #expect(!body.contains("1"))
            #expect(!body.contains("I"))
        }
    }

    /// Two generated keys should (practically) never collide.
    @Test("Licence keys are unique")
    public func keysAreUnique() {
        let keys = Set((0 ..< 100).map { _ in LicenseService.generateKey() })
        #expect(keys.count == 100)
    }
}
