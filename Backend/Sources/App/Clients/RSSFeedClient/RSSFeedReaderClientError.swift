// RSSFeedReaderClientError.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

/// Errors that can occur during RSS feed reading operations.
/// These errors provide specific information about failures in the RSS feed reading process.
internal enum RSSFeedReaderClientError: Error {
    /// Indicates that the client failed to read or parse a feed from a URL.
    /// - Parameter error: The underlying error that caused the failure.
    case failedToReadFeed(_ error: Error)
}
