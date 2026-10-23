// UserIsAcceptedDTO.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

/// A data transfer object (DTO) that represents whether a user is accepted.
/// This struct conforms to Vapor's `Content` protocol for HTTP encoding/decoding.
public struct UserIsAcceptedDTO: Content {
    /// A boolean value indicating whether the user is accepted.
    /// - `true` indicates the user is accepted
    /// - `false` indicates the user is not accepted
    public var accepted: Bool

    /// Initializes a new UserIsAcceptedDTO instance.
    /// - Parameter accepted: A boolean value indicating whether the user is accepted.
    public init(accepted: Bool) {
        // Set the accepted status
        self.accepted = accepted
    }
}
