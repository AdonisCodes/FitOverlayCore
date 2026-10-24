// FeedTesterControllerInteractor.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Alamofire
import DataTypes
import Foundation

/// A controller interactor that handles feed testing functionality
/// This interactor can be used for 3rd party APIs on both frontend and backend.
/// Gets automatically generated when creating a backend-controller on the client.
internal struct FeedTesterControllerInteractor: BackendControllerInteractor {
    /// The base URL used for making API requests
    public let baseURL: String

    /// Makes a GET request to the feed tester endpoint
    ///
    /// This method sends a request to the "/Feed-Tester/request" endpoint to test feed functionality
    ///
    /// - Returns: A DataResponse object containing optional Data and any Alamofire errors that occurred
    /// - Throws: An error if the request fails or cannot be completed
    public func makeRequest() async throws -> DataResponse<Data?, AFError> {
        await performRequest(
            endpoint: "/Feed-Tester/request",
            method: .get
        )
    }
}
