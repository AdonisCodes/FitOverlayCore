// AuthenticationCodeResponseDTO.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

/// A data transfer object (DTO) representing the response for authentication code operations.
/// This struct conforms to Vapor's `Content` protocol for HTTP message encoding and decoding.
public struct AuthenticationCodeResponseDTO: Content {
    /// Indicates whether the authentication code operation was successful.
    public let success: Bool

    /// The timeout duration in seconds for the authentication code.
    public let timeout: Double

    /// Initializes a new authentication code response DTO.
    /// - Parameters:
    ///   - success: A boolean indicating if the authentication operation was successful.
    ///   - timeout: The duration in seconds until the authentication code expires.
    public init(success: Bool, timeout: Double) {
        // Set the success status of the authentication operation
        self.success = success
        // Set the timeout duration for the authentication code
        self.timeout = timeout
    }
}
