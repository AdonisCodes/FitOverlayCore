// ControllerInteractor.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Alamofire
import Vapor

/// Protocol used on the client and integration tests to call endpoints for a controller
/// (collection of routes). This protocol defines the basic requirements for making HTTP requests
/// to controller endpoints.
public protocol ControllerInteractor {
    /// The base URL of the server to which requests will be made
    /// This should include the scheme (http/https) and domain
    var baseURL: String { get }

    /// The Alamofire session used to make network requests
    /// This session manages the underlying URLSession and request configuration
    var session: Alamofire.Session { get }

    /// Makes an HTTP request to a specific endpoint and returns the Alamofire response
    ///
    /// This method handles the creation and execution of HTTP requests using Alamofire
    ///
    /// - Parameters:
    ///   - endpoint: The specific route endpoint to call (e.g., "/users")
    ///   - method: The HTTP method to use (GET, POST, PUT, DELETE, etc.)
    ///   - headers: Optional HTTP headers to include in the request
    ///   - parameters: Optional parameters to be included in the request body or query string
    ///   - encoding: The method to use for parameter encoding (e.g., JSON, URL encoding)
    ///
    /// - Throws: An error if the request fails to execute
    /// - Returns: An Alamofire DataResponse object containing the response data and any errors
    func performRequest(
        endpoint: String,
        method: Alamofire.HTTPMethod,
        headers: Alamofire.HTTPHeaders?,
        parameters: Alamofire.Parameters?,
        encoding: ParameterEncoding
    ) async throws -> DataResponse<Data?, AFError>
}

/// Default implementations for the ControllerInteractor protocol
/// Provides concrete implementations of common functionality
public extension ControllerInteractor {
    /// Default Alamofire session implementation
    /// Returns the shared default session instance
    var session: Alamofire.Session {
        .default
    }

    /// Default implementation of performRequest that executes an HTTP request
    /// This implementation handles the async request execution using continuation
    func performRequest(
        endpoint: String,
        method: Alamofire.HTTPMethod,
        headers: Alamofire.HTTPHeaders? = nil,
        parameters: Alamofire.Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default
    ) async -> DataResponse<Data?, AFError> {
        // Construct the full URL by combining base URL and endpoint
        let url = "\(baseURL)\(endpoint)"

        // Use continuation to wrap the asynchronous Alamofire request
        return await withCheckedContinuation { continuation in
            self.session.request(
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

/// A generic structure that represents the response from a backend controller endpoint
/// This structure includes both the response data and any potential errors
public struct BackendControllerResponseOutput<K: Content> {
    /// The decoded response data of type K, which must conform to Content protocol
    /// This will be nil if there was an error or no data was returned
    public let data: K?

    /// Any error that occurred during the request or response processing
    /// This will be nil if the request was successful
    public let error: GenericErrors?

    /// Initializes a new instance of BackendControllerResponseOutput
    ///
    /// - Parameters:
    ///   - data: The optional response data of type K
    ///   - error: An optional error that occurred during the request or processing
    public init(data: K?, error: GenericErrors?) {
        self.data = data
        self.error = error
    }
}

/// Protocol for interacting specifically with backend controllers
/// Extends ControllerInteractor with additional functionality for handling backend responses
public protocol BackendControllerInteractor: ControllerInteractor {
    /// Decodes a network response into the expected Content type
    ///
    /// - Parameters:
    ///   - data: The raw response data from the network request
    ///   - decodeTo: The expected type to decode the response into
    ///
    /// - Returns: A BackendControllerResponseOutput containing either the decoded data or an error
    func decodeResponse<K: Content>(
        _ data: DataResponse<Data?, AFError>,
        _ decodeTo: K.Type
    ) -> BackendControllerResponseOutput<K>
}

/// Default implementations for BackendControllerInteractor
/// Provides concrete implementations for response handling and decoding
public extension BackendControllerInteractor {
    /// Processes a response and returns the expected Content type or throws an error
    ///
    /// - Parameters:
    ///   - response: The raw response from the network request
    ///   - decodeTo: The type to decode the response into
    ///   - rethrow: Array of errors that should be rethrown directly if encountered
    ///
    /// - Throws: GenericErrors depending on the response state
    /// - Returns: The decoded response data of type K
    func handleResponse<K: Content>(
        response: DataResponse<Data?, AFError>,
        decodeTo: K.Type,
        rethrow: [GenericErrors]
    ) throws -> K {
        let output = decodeResponse(
            response,
            decodeTo.self
        )

        if let error = output.error {
            print("Error checking if user exists: \(error.localizedDescription)")

            // Check if the error should be rethrown directly
            try rethrow.forEach { rethrowError in
                if rethrowError == error {
                    throw error
                }
            }
            throw GenericErrors.unknownError
        }

        guard let data = output.data else {
            throw GenericErrors.unexpectedApiStateNoErrorAndNoResponse
        }

        return data
    }

    /// Decodes the response data and handles any Alamofire errors
    ///
    /// - Parameters:
    ///   - data: The response data to decode
    ///   - decodeTo: The type to decode into
    ///
    /// - Returns: A BackendControllerResponseOutput containing the decoded data or error
    func decodeResponse<K: Content>(
        _ data: DataResponse<Data?, AFError>,
        _ decodeTo: K.Type
    ) -> BackendControllerResponseOutput<K> {
        if let alamofireError = data.error, getErrorFromResponse(data.data) == nil {
            if isNetworkOrConnectionError(alamofireError) {
                return .init(data: nil, error: .networkConnectivityError)
            }
            return .init(data: nil, error: .alamofireError)
        }

        return decodeResponse(data.data, decodeTo)
    }

    // Private helper methods

    /// Decodes raw data into a BackendControllerResponseOutput
    ///
    /// - Parameters:
    ///   - data: The raw data to decode
    ///   - K: The type to decode into
    ///
    /// - Returns: A BackendControllerResponseOutput containing the decoded data or error
    private func decodeResponse<K: Content>(
        _ data: Data?,
        _: K.Type
    ) -> BackendControllerResponseOutput<K> {
        let error = getErrorFromResponse(data)

        if let error {
            return .init(data: nil, error: error)
        }

        do {
            let value = try K.decodeJSONFromData(data: data)
            return .init(data: value, error: nil)
        } catch {
            return .init(data: nil, error: .failedToDecodeResponse)
        }
    }

    /// Determines if an error is related to network connectivity
    ///
    /// - Parameter error: The error to check
    /// - Returns: True if the error is a network-related error
    private func isNetworkOrConnectionError(_ error: Error?) -> Bool {
        guard let error = error as? URLError else { return false }

        let networkConnectionErrors = [
            URLError.timedOut,
            URLError.networkConnectionLost,
            URLError.notConnectedToInternet,
            URLError.networkConnectionLost,
            URLError.cannotFindHost,
            URLError.cannotConnectToHost,
            URLError.unsupportedURL,
            URLError.resourceUnavailable,
        ]

        return networkConnectionErrors.contains(error.code)
    }

    /// Extracts an error from response data if present
    ///
    /// - Parameter data: The response data to check for errors
    /// - Returns: A GenericErrors instance if an error is found, nil otherwise
    private func getErrorFromResponse(
        _ data: Data?
    ) -> GenericErrors? {
        guard let data else { return nil }

        let decoder = JSONDecoder()
        do {
            let value = try decoder.decode(ResponseError.self, from: data)
            return value.error
        } catch {
            return nil
        }
    }
}

/// Extension to provide convenient access to response status codes
public extension DataResponse {
    /// Retrieves the HTTP status code from the response
    ///
    /// - Returns: The HTTP status code as an optional Int
    func statusCode() -> Int? {
        response?.statusCode
    }
}
