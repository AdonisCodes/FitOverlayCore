// UserIsAcceptedDTO.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

/// Legacy response for clients that still ask whether an account was approved.
/// The app no longer reviews accounts, so `accepted` is always true.
/// This struct conforms to Vapor's `Content` protocol for HTTP encoding/decoding.
public struct UserIsAcceptedDTO: Content {
    /// Always true. Accounts are not reviewed.
    public var accepted: Bool

    /// Initializes a new UserIsAcceptedDTO instance.
    /// - Parameter accepted: A boolean value indicating whether the user is accepted.
    public init(accepted: Bool) {
        // Set the accepted status
        self.accepted = accepted
    }
}
