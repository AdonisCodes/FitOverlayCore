// AccessTokenPayloadDTO.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

/// A data transfer object (DTO) that represents an access token payload.
/// This struct conforms to Vapor's Content protocol to enable easy encoding/decoding in HTTP requests and responses.
public struct AccessTokenPayloadDTO: Content {
    /// The access token string value.
    /// This token is used for authentication and authorization purposes.
    public var accessToken: String

    /// Initializes a new AccessTokenPayloadDTO instance.
    /// - Parameter accessToken: The access token string to be stored in this DTO.
    public init(accessToken: String) {
        // Store the provided access token
        self.accessToken = accessToken
    }
}
