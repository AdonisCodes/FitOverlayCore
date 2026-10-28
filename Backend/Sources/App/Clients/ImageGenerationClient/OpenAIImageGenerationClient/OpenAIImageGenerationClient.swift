// OpenAIImageGenerationClient.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Foundation
import OpenAI
import Retry
import Vapor

/// A client for generating images using OpenAI's API.
/// This client handles image generation requests by communicating with OpenAI's DALL-E models.
/// It supports both DALL-E 2 and DALL-E 3, with configurable parameters for image generation.
public struct OpenAIImageGenerationClient: ImageGenerationClientBase {
    /// The underlying OpenAI client used for API communication
    private let client: OpenAI

    /// Logger instance for tracking operations and errors
    public let logger: Logger

    /// Initializes a new OpenAI image generation client
    /// - Parameters:
    ///   - logger: The logger instance to use for operation tracking
    ///   - timeout: The timeout interval for API requests in seconds (defaults to 180)
    /// - Throws: An error if the OPENAI_API_KEY environment variable is not set
    public init(
        logger: Logger,
        timeout: TimeInterval = 180
    ) throws {
        let token = try Environment.getOrThrow("OPENAI_API_KEY")
        client = .init(
            configuration: .init(
                token: token,
                timeoutInterval: timeout
            )
        )
        self.logger = logger
    }

    /// Generates images based on the provided query parameters
    /// - Parameter query: The query containing generation parameters like prompt, model, size, etc.
    /// - Returns: A GenerateImageResult containing the generated images and metadata
    /// - Throws: OpenAIImageGenerationClientError if generation or encoding fails
    public func generateImage(_ query: GenerateImageQuery) async throws -> GenerateImageResult {
        // Start the backend metric for image generation request
        BackendMetric.openAIImageGenerationRequest(status: .start).increment()

        var imageQuality: ImagesQuery.Quality?
        var imageSize: ImagesQuery.Size?
        var imageStyle: ImagesQuery.Style?

        if let quality = query.quality?.rawValue {
            imageQuality = .init(rawValue: quality)
        }
        if let size = query.imageSize?.rawValue {
            imageSize = .init(rawValue: size)
        }
        if let style = query.imageStyle?.rawValue {
            imageStyle = .init(rawValue: style)
        }

        // Create the query for image generation
        let queryForImageGeneration: ImagesQuery = try .init(
            prompt: query.prompt,
            model: getModel(from: query.model),
            n: query.totalImagesToGenerate,
            quality: imageQuality,
            responseFormat: .b64_json,
            size: imageSize,
            style: imageStyle
        )
        var result: ImagesResult?

        do {
            // Attempt to generate images with retry logic
            try await retry(maxAttempts: 3) {
                result = try await client.images(query: queryForImageGeneration)
            }
        } catch {
            // Log and throw an error if image generation fails
            BackendMetric.openAIImageGenerationRequest(status: .fail).increment()
            logger.error(
                "Failed to generate image",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string(String(reflecting: error)),
                    "query": .string(String(reflecting: query)),
                    "queryForImageGeneration": .string(String(reflecting: queryForImageGeneration)),
                ]
            )
            throw OpenAIImageGenerationClientError.generationError(error)
        }

        // Ensure the result is not nil
        guard
            let result
        else {
            throw OpenAIImageGenerationClientError.generationError()
        }

        // Log successful image generation
        logger.info(
            "Successfully generated response.",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
            ]
        )

        let resultData: Data
        let images: [Data]

        do {
            // Encode the result and extract images
            resultData = try JSONEncoder().encode(result)
            images = try result.data.map { image in
                guard
                    let imageB64String = image.b64Json,
                    let data = Data(base64Encoded: imageB64String)
                else {
                    throw OpenAIImageGenerationClientError.responseError
                }
                return data
            }
        } catch {
            // Log and throw an error if encoding fails
            BackendMetric.openAIImageGenerationRequest(status: .fail).increment()
            logger.error(
                "Failed to encode result or images response.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string(String(reflecting: error)),
                ]
            )
            throw OpenAIImageGenerationClientError.encodeError(error)
        }

        // Increment the success metric
        BackendMetric.openAIImageGenerationRequest(status: .success).increment()

        // Return the generated images and metadata
        return .init(
            images: images,
            metadataJSON: resultData
        )
    }

    /// Converts the GenerateImageModel to OpenAI's Model type
    /// - Parameter model: The GenerateImageModel to convert
    /// - Returns: The corresponding OpenAI Model
    private func getModel(from model: GenerateImageModel) throws -> Model {
        switch model {
        case .dall_e_2:
            .dall_e_2
        case .dall_e_3:
            .dall_e_3
        }
    }
}
