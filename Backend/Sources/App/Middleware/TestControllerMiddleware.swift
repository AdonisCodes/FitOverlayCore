// TestControllerMiddleware.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import AutomaUtilities
import DataTypes
import Vapor

/// Middleware to ensure requests to test controllers are authenticated using a specific header key.
internal struct TestControllerMiddleware: AsyncMiddleware {
    /// Responds to a request by checking for a valid test controller key in the headers.
    /// - Parameters:
    ///   - request: The incoming request to be processed.
    ///   - next: The next responder in the middleware chain.
    /// - Returns: A `Response` object if the header key is valid.
    /// - Throws: Throws `Abort.unauthorized` if the header key is missing or invalid.
    public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        // Retrieve the expected test controller key from the environment
        let testsControllerKey = try Environment.getOrThrow("TEST_CONTROLLERS_KEY")

        // Check if the request contains the required header
        guard
            let headerValue = request.headers.first(name: "X-Tests-Controller-Key")
        else {
            // Log an error if the header is missing
            request.logger.error("Missing X-Tests-Controller-Key header")
            throw Abort(.unauthorized)
        }

        // Validate the header value against the expected key
        if headerValue != testsControllerKey {
            // Log an error if the header value is invalid
            request.logger.error("Invalid X-Tests-Controller-Key header")
            throw Abort(.unauthorized)
        }

        // Proceed to the next middleware if the header is valid
        return try await next.respond(to: request)
    }
}
