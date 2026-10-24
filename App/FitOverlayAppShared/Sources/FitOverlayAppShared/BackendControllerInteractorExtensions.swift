// BackendControllerInteractorExtensions.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Alamofire
import DataTypes
import Foundation

/// Extension to BackendControllerInteractor that provides network request functionality
public extension BackendControllerInteractor {
    /// Performs an HTTP request to the specified endpoint with optional authentication
    ///
    /// This method handles network requests with configurable parameters and optional JWT authentication.
    /// If JWT authentication is enabled, it will attempt to retrieve an authentication token from the keychain
    /// and add it to the request headers.
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint to send the request to
    ///   - method: The HTTP method to use for the request (GET, POST, etc.)
    ///   - headers: Optional HTTP headers to include in the request
    ///   - parameters: Optional parameters to be encoded in the request
    ///   - encoding: The parameter encoding to use (defaults to JSONEncoding.default)
    ///   - jwt: Boolean flag indicating whether to include JWT authentication (defaults to false)
    ///
    /// - Returns: A DataResponse object containing the response data or error
    ///
    /// - Note: The method uses async/await pattern and internally manages the continuation
    func performRequest(
        endpoint: String,
        method: Alamofire.HTTPMethod,
        headers: Alamofire.HTTPHeaders? = nil,
        parameters: Alamofire.Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        jwt: Bool = false
    ) async -> DataResponse<Data?, AFError> {
        var headers = headers ?? Alamofire.HTTPHeaders()

        if jwt {
            if let token = await KeychainHelper.get(for: .authenticationToken) {
                headers.add(.authorization(bearerToken: token))
            } else {
                print("No authentication token found in Keychain.")
            }
        }

        let url = "\(baseURL)\(endpoint)"

        return await withCheckedContinuation { continuation in
            self.session
                .request(
                    url,
                    method: method,
                    parameters: parameters,
                    encoding: encoding,
                    headers: headers
                )
                .validate()
                .response { response in
                    continuation.resume(returning: response)
                }
        }
    }
}
