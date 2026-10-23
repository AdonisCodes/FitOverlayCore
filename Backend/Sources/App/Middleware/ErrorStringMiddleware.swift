// ErrorStringMiddleware.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import DataTypes
import Vapor

/// Middleware to handle errors and convert them into JSON responses.
internal struct ErrorStringMiddleware: Middleware {
    /// Responds to a request by processing errors and returning a JSON response.
    /// - Parameters:
    ///   - request: The incoming request to be processed.
    ///   - next: The next responder in the middleware chain.
    /// - Returns: An `EventLoopFuture<Response>` containing the JSON error response.
    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        // Attempt to respond to the request and handle any errors
        next.respond(to: request).flatMapErrorThrowing { error in
            let response = Response()
            response.status = .internalServerError
            response.headers.replaceOrAdd(
                name: .contentType, value: "application/json; charset=utf-8"
            )

            // Determine the reason for the error
            let reason: DataTypes.GenericErrors =
                if let genericError = error as? DataTypes.GenericErrors {
                    genericError
                } else if error is AbortError {
                    GenericErrors.abortError
                } else {
                    GenericErrors.unknownError
                }

            // Log specific error details based on the reason
            if reason == .abortError {
                request.logger.error(
                    "Unknown Error (Abort) occurred",
                    metadata: [
                        "to": .string("ErrorStringMiddleware.respond"),
                        "localizedDescription": .string(error.localizedDescription),
                    ]
                )
            }

            if reason == .unknownError, let localizedError = error as? LocalizedError {
                request.logger.error(
                    "Unknown Error occurred",
                    metadata: [
                        "to": .string("ErrorStringMiddleware.respond"),
                        "localizedDescription": .string(localizedError.localizedDescription),
                        "localizedError": .string(localizedError.errorDescription ?? ""),
                        "localizedFailureReason": .string(localizedError.failureReason ?? ""),
                    ]
                )
            }

            // Create a JSON response with the error details
            let jsonResponse: ResponseError = .init(error: reason)

            do {
                response.body = try .init(
                    data: jsonResponse.encodeToData()
                )
            } catch {
                // Log an error if encoding the response fails
                request.logger.error(
                    "Failed to encode response",
                    metadata: [
                        "to": .string("ErrorStringMiddleware.respond"),
                        "localizedDescription": .string(error.localizedDescription),
                    ]
                )
                response.body = .init(
                    stringLiteral: "{\"error\":\"\(GenericErrors.failedToEncodeResponse)\"}"
                )
            }

            return response
        }
    }
}
