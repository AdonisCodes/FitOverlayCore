// OpenAIImageGenerationClientError.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

/// An enumeration representing errors that can occur in the OpenAIImageGenerationClient.
///
/// This enum defines specific error cases that the OpenAIImageGenerationClient might encounter
/// during its operations, such as encoding failures, generation errors, invalid models, and response errors.
internal enum OpenAIImageGenerationClientError: Error {
    /// Indicates an error occurred during encoding.
    ///
    /// This error is thrown when the client fails to encode the result or images response.
    case encodeError((any Error)?)

    /// Indicates an error occurred during image generation.
    ///
    /// This error is thrown when the client fails to generate images using the provided query parameters.
    case generationError((any Error)? = nil)

    /// Indicates that an invalid model was specified for image generation.
    ///
    /// This error is thrown when the client encounters an unsupported or unrecognized model type.
    case invalidModel

    /// Indicates an error occurred while processing the response.
    ///
    /// This error is thrown when the client receives an invalid or unexpected response from the OpenAI API.
    case responseError
}
