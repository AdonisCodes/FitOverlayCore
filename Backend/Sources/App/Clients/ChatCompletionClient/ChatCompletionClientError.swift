// ChatCompletionClientError.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

/// Errors that can occur during chat completion operations
/// These errors represent various failure modes when interacting with AI chat completion services
internal enum ChatCompletionClientError: Error {
    /// General error during the completion process
    /// This can include network errors, authentication failures, or other API-related issues
    case completionError

    /// Error indicating that the completion was successful but returned an empty message
    /// This typically indicates an issue with the model's response formatting or content filtering
    case completionMessageEmpty

    /// Could not create messages array to send to platform, because a message was empty
    case requestMessageNil
}
