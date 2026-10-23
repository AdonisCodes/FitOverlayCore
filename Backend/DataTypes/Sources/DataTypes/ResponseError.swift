// ResponseError.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

/// Represents an error response structure that can be sent over the network
/// Conforms to Vapor's Content protocol for HTTP response handling
public struct ResponseError: Content {
    /// The specific error that occurred
    public let error: GenericErrors

    /// Initializes a new ResponseError
    /// - Parameter error: The GenericErrors case to be wrapped in the response
    public init(error: GenericErrors) {
        self.error = error
    }
}
