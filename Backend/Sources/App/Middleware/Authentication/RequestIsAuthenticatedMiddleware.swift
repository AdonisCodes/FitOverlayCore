// RequestIsAuthenticatedMiddleware.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import AutomaUtilities
import DataTypes
import Vapor

/// Middleware to authenticate requests using JWT tokens.
internal struct RequestIsAuthenticatedMiddleware: AsyncMiddleware {
    /// Responds to a request by verifying the JWT token and proceeding if valid.
    /// - Parameters:
    ///   - request: The incoming request to be processed.
    ///   - next: The next responder in the middleware chain.
    /// - Returns: A `Response` object if the token is valid.
    /// - Throws: Throws `GenericErrors.invalidToken` if the token is invalid.
    public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        // Verify the JWT token from the request
        let tokenPayload = try await request.jwt.verify(as: JWTTokenPayload.self)
        let messageService = MessageService()

        do {
            // Find the token in the database
            let token = try await JwtTokenModel.find(
                tokenPayload.tokenId,
                on: request.dbReadOnly
            )

            // If the token exists, proceed to the next middleware
            if token != nil {
                return try await next.respond(to: request)
            } else {
                // Log an error if the token is invalid
                request.logger.error(
                    "User Token is invalid",
                    metadata: [
                        "to": .string("RequestIsAuthenticatedMiddleware.respond"),
                        "token": .string(
                            request.headers.bearerAuthorization?.token ?? ""
                        ),
                    ]
                )
                throw GenericErrors.invalidToken
            }
        } catch {
            // Handle known errors
            if let error = error as? GenericErrors {
                throw error
            }

            // Log and alert for unknown errors
            request.logger.critical(
                "Unknown error in Authentication Middleware",
                metadata: [
                    "to": .string("RequestIsAuthenticatedMiddleware.respond"),
                    "error": .string(error.localizedDescription),
                ]
            )

            try messageService.sendDiscordAlert(
                alertTitle: "Error in Authentication Middleware",
                error: error,
                logger: request.logger
            )

            throw error
        }
    }
}
