// TwitterAuthenticatedClientError.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import TwitterAPIKit

/// Errors that can occur when making authenticated requests to the Twitter API
internal enum TwitterAuthenticatedClientError: Error {
    /// The Twitter API response was empty or nil when data was expected
    case responseEmpty

    /// Error returned from Twitter API request.
    case twitterAPIKitResponseError(TwitterAPIKitError)

    /// Error returned from Twitter API request
    case twitterAPIResponseError(TwitterAPIError)
}
