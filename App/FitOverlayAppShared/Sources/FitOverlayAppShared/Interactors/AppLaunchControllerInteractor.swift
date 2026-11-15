// AppLaunchControllerInteractor.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Alamofire
import DataTypes
import Foundation

/// Interactor responsible for handling app launch-related network requests
///
/// This struct provides methods to retrieve client configuration from the backend server
/// during app launch. It conforms to `BackendControllerInteractor` to utilize common
/// networking functionality.
public struct AppLaunchControllerInteractor: BackendControllerInteractor {
    /// The base URL for all API requests
    ///
    /// This URL is used as the prefix for all endpoints when making network requests
    public let baseURL: String

    /// Retrieves the client configuration from the server
    ///
    /// Makes a GET request to fetch the current client configuration settings.
    /// This configuration may include feature flags, API endpoints, and other
    /// client-specific settings.
    ///
    /// - Returns: An `AppLaunchClientConfigDTO` containing the client configuration
    /// - Throws: Network connectivity errors or other request-related exceptions
    public func makeGetClientConfig() async throws -> AppLaunchClientConfigDTO {
        let response = await performRequest(
            endpoint: "/App-Launch/get-client-config",
            method: .get
        )

        return try handleResponse(
            response: response,
            decodeTo: AppLaunchClientConfigDTO.self,
            rethrow: [
                .networkConnectivityError,
            ]
        )
    }
}
