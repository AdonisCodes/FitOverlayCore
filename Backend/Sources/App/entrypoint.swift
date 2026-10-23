// entrypoint.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Logging
import NIOCore
import NIOPosix
import Vapor

/// The main entry point for the application.
@main
internal enum Entrypoint {
    /// The main function that initializes and runs the application.
    /// - Throws: Throws an error if the application fails to start or execute.
    public static func main() async throws {
        // Detect the current environment configuration
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)

        // Create a new application instance with the detected environment
        let app = try await Application.make(env)

        do {
            // Configure the application
            try await configure(app)
        } catch {
            // Report any errors that occur during configuration
            app.logger.report(error: error)
            // Attempt to shut down the application gracefully
            try? await app.asyncShutdown()
            // Rethrow the error to indicate failure
            throw error
        }

        // Execute the application
        try await app.execute()
        // Shut down the application after execution
        try await app.asyncShutdown()
    }
}
