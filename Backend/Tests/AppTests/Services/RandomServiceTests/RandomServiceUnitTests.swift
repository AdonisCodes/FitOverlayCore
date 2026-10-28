// RandomServiceUnitTests.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

@testable import App
import Testing

/// Unit tests for `RandomService`.
@Suite("RandomServiceUnitTests")
internal struct RandomServiceUnitTests {
    /// Random usernames should be non-empty and unique-ish thanks to the random suffix.
    @Test("Random username has random suffix")
    public func randomUsername() {
        let one = RandomService.randomUsername()
        let two = RandomService.randomUsername()
        #expect(!one.isEmpty)
        #expect(one != two)
    }

    /// Random codes should be two lowercase words joined by a dash.
    @Test("Random code format")
    public func randomCode() {
        let code = RandomService.randomCode()
        let parts = code.split(separator: "-")
        #expect(parts.count == 2)
        #expect(code == code.lowercased())
    }
}
