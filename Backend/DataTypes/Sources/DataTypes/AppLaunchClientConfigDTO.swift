// AppLaunchClientConfigDTO.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

/// A data transfer object (DTO) that represents client configuration information during app launch.
/// This struct conforms to Vapor's `Content` protocol to enable automatic encoding/decoding in HTTP requests.
public struct AppLaunchClientConfigDTO: Content {
    /// The minimum required version of the client application.
    /// This version string follows semantic versioning format (e.g., "1.0.0").
    public let requiredClientVersion: String

    /// Initializes a new instance of `AppLaunchClientConfigDTO`.
    /// - Parameter currentAppVersion: The current version of the application.
    ///                               Defaults to "0.0.0" if not specified.
    /// - Returns: A new `AppLaunchClientConfigDTO` instance with the specified version requirements.
    public init(currentAppVersion: String = "0.0.0") {
        // Set the required client version to match the current app version
        requiredClientVersion = currentAppVersion
    }
}
