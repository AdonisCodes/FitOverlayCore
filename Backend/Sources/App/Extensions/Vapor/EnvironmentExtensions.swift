// EnvironmentExtensions.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

/// Error thrown when a required environment variable is missing.
internal struct MissingEnvironmentVariableError: Error, CustomStringConvertible {
    /// The missing environment variable key
    public let key: String

    public var description: String {
        "Missing required environment variable: \(key)"
    }
}

internal extension Environment {
    /// Returns the value for an environment variable or throws when it is not set.
    /// - Parameter key: The environment variable name.
    /// - Returns: The environment variable value.
    /// - Throws: `MissingEnvironmentVariableError` when the variable is not set.
    static func getOrThrow(_ key: String) throws -> String {
        guard let value = Environment.get(key) else {
            throw MissingEnvironmentVariableError(key: key)
        }
        return value
    }
}
