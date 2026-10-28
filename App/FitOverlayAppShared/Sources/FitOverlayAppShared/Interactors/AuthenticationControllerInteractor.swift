// AuthenticationControllerInteractor.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Alamofire
import DataTypes
import Foundation

// NOTE: This ControllerInteractor can be used for 3rd party apis on both the frontend + backend
// A ControllerInteractor automatically gets generated when creating a backend-controller (on client)

/// Handles authentication-related network requests to the backend server
///
/// This struct provides methods for user registration, login, and token refresh operations.
/// It conforms to `BackendControllerInteractor` to utilize common networking functionality.
internal struct AuthenticationControllerInteractor: BackendControllerInteractor {
    /// The base URL for all API requests
    ///
    /// This URL is used as the prefix for all endpoints when making network requests
    public let baseURL: String

    /// Requests a registration verification code for a new user
    ///
    /// Makes a POST request to send a verification code to the provided phone number
    /// for new user registration.
    ///
    /// - Parameter phoneNumber: The phone number to send the verification code to
    /// - Returns: An `AuthenticationCodeResponseDTO` containing the verification details
    /// - Throws: User already exists error or network connectivity issues
    public func makeRegisterCodeRequest(_ phoneNumber: String) async throws -> AuthenticationCodeResponseDTO {
        let params = try PhoneNumberPayloadDTO(number: phoneNumber).encodeToDictionary()

        let response = await performRequest(
            endpoint: "/Authentication/register-code",
            method: .post,
            parameters: params
        )

        return try handleResponse(
            response: response,
            decodeTo: AuthenticationCodeResponseDTO.self,
            rethrow: [
                .userAlreadyExists,
                .networkConnectivityError,
            ]
        )
    }

    /// Registers a new user with a verified phone number
    ///
    /// Makes a POST request to register a new user after they have received and entered
    /// a valid verification code.
    ///
    /// - Parameters:
    ///   - phoneNumber: The phone number being registered
    ///   - code: The verification code received by the user
    /// - Returns: An `AuthenticationTokensPayloadDTO` containing access and refresh tokens
    /// - Throws: User exists error, invalid code error, or network connectivity issues
    public func makeRegisterRequest(
        _ phoneNumber: String,
        _ code: String
    ) async throws -> AuthenticationTokensPayloadDTO {
        let params = try AuthPhoneCodePayloadDTO(phoneNumber: phoneNumber, code: code).encodeToDictionary()

        let response = await performRequest(
            endpoint: "/Authentication/register",
            method: .post,
            parameters: params
        )

        return try handleResponse(
            response: response,
            decodeTo: AuthenticationTokensPayloadDTO.self,
            rethrow: [
                .userAlreadyExists,
                .invalidCode,
                .networkConnectivityError,
            ]
        )
    }

    /// Requests a login verification code for an existing user
    ///
    /// Makes a POST request to send a verification code to the provided phone number
    /// for user login.
    ///
    /// - Parameter phoneNumber: The phone number to send the verification code to
    /// - Returns: An `AuthenticationCodeResponseDTO` containing the verification details
    /// - Throws: User not found error, invalid code error, or network connectivity issues
    public func makeLoginCodeRequest(_ phoneNumber: String) async throws -> AuthenticationCodeResponseDTO {
        let params = try PhoneNumberPayloadDTO(number: phoneNumber).encodeToDictionary()

        let response = await performRequest(
            endpoint: "/Authentication/login-code",
            method: .post,
            parameters: params
        )

        return try handleResponse(
            response: response,
            decodeTo: AuthenticationCodeResponseDTO.self,
            rethrow: [
                .userNotFound,
                .invalidCode,
                .networkConnectivityError,
            ]
        )
    }

    /// Logs in an existing user with a verified phone number
    ///
    /// Makes a POST request to authenticate a user after they have received and entered
    /// a valid verification code.
    ///
    /// - Parameters:
    ///   - phoneNumber: The phone number being used to login
    ///   - code: The verification code received by the user
    /// - Returns: An `AuthenticationTokensPayloadDTO` containing access and refresh tokens
    /// - Throws: User not found error, invalid code error, or network connectivity issues
    public func makeLoginRequest(_ phoneNumber: String, _ code: String) async throws -> AuthenticationTokensPayloadDTO {
        let params = try AuthPhoneCodePayloadDTO(phoneNumber: phoneNumber, code: code).encodeToDictionary()

        let response = await performRequest(
            endpoint: "/Authentication/login",
            method: .post,
            parameters: params
        )

        return try handleResponse(
            response: response,
            decodeTo: AuthenticationTokensPayloadDTO.self,
            rethrow: [
                .userNotFound,
                .invalidCode,
                .networkConnectivityError,
            ]
        )
    }

    /// Refreshes an expired access token using a refresh token
    ///
    /// Makes a GET request to obtain a new access token using a valid refresh token.
    /// If the refresh token is invalid, executes the provided handler.
    ///
    /// - Parameters:
    ///   - refreshToken: The refresh token to use for obtaining a new access token
    ///   - handleInvalidToken: A closure to execute if the refresh token is invalid
    /// - Returns: An `AccessTokenPayloadDTO` containing the new access token
    /// - Throws: Invalid user ID error, user not found error, or network connectivity issues
    public func makeRefreshTokenRequest(
        _ refreshToken: String,
        handleInvalidToken: @escaping () async throws -> Void
    ) async throws -> AccessTokenPayloadDTO {
        let params = ["xxrt": refreshToken]

        let response = await performRequest(
            endpoint: "/Authentication/refresh-token",
            method: .get,
            parameters: params,
            encoding: URLEncoding.default
        )

        let data = try handleResponse(
            response: response,
            decodeTo: AccessTokenPayloadDTO.self,
            rethrow: [
                .invalidUserId,
                .userNotFound,
                .networkConnectivityError,
            ]
        )

        let output = decodeResponse(response, AccessTokenPayloadDTO.self)
        if output.error == .invalidToken {
            try await handleInvalidToken()
        }

        return data
    }
}
