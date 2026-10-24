// AppLaunch.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import DataTypes
import SwiftUI

/// Handles application launch and authentication flow
///
/// This struct manages the initial app launch sequence including:
/// - Authentication token management
/// - User acceptance status verification
/// - Client configuration retrieval
public struct AppLaunch: Sendable {
    /// The base URL for API requests
    public let baseURL: String

    /// Creates a new AppLaunch instance
    ///
    /// - Parameter baseURL: The base URL for API requests
    public init(baseURL: String) {
        self.baseURL = baseURL
    }

    /// Retrieves and validates the access token
    ///
    /// This method:
    /// 1. Checks for an existing refresh token
    /// 2. If found, attempts to get a new access token
    /// 3. Updates keychain storage with new tokens
    ///
    /// - Returns: A boolean indicating if a valid access token was obtained
    public func getAccessToken() async -> Bool {
        let authenticationController = AuthenticationControllerInteractor(baseURL: baseURL)
        let keychain = KeychainHelper.self

        print("Access Token")
        var shouldReturn = false
        if let refreshToken = await keychain.get(for: .refreshToken) {
            let newAccessToken = try? await authenticationController.makeRefreshTokenRequest(
                refreshToken
            ) {
                await keychain.delete(for: .refreshToken)
                await keychain.delete(for: .authenticationToken)
                shouldReturn = true
            }

            if shouldReturn {
                return false
            }

            if let newAccessToken {
                await keychain
                    .set(
                        for: .authenticationToken,
                        value: newAccessToken.accessToken
                    )
                return true
            } else {
                await keychain.delete(for: .refreshToken)
                await keychain.delete(for: .authenticationToken)
                return false
            }
        }
        return false
    }

    /// Checks if the current user has accepted the terms of service
    ///
    /// - Returns: A boolean indicating if the user has accepted the terms
    /// - Note: Returns false if there is an error checking the acceptance status
    public func isUserAccepted() async -> Bool {
        let appLaunchInteractor = AppLaunchControllerInteractor(baseURL: baseURL)
        do {
            return try await appLaunchInteractor.makeIsUserAcceptedRequest()
        } catch {
            print("Unknown Response Error, Returning False")
            return false
        }
    }

    /// Retrieves the client configuration from the server
    ///
    /// This method fetches configuration settings including:
    /// - Required client version
    /// - Feature flags
    /// - Other server-defined settings
    ///
    /// - Returns: An AppLaunchClientConfigDTO containing the configuration
    /// - Note: Returns a default configuration if there is an error fetching from server
    public func getClientConfig() async -> AppLaunchClientConfigDTO {
        let appLaunchInteractor = AppLaunchControllerInteractor(baseURL: baseURL)
        do {
            return try await appLaunchInteractor.makeGetClientConfig()
        } catch {
            print("Unknown Response Error, Returning Default Type")
            return .init()
        }
    }
}
