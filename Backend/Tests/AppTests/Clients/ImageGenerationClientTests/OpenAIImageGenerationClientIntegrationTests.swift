// OpenAIImageGenerationClientIntegrationTests.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

@testable import App
import Fluent
import OpenAI
import Testing
import VaporTesting

/// Tests for the OpenAI Image Generation Client implementation
/// These tests verify the functionality of image generation using both DALL-E 2 and DALL-E 3 models
@Suite("OpenAIImageGenerationClientIntegrationTests")
internal struct OpenAIImageGenerationClientIntegrationTests: ImageGenerationClientTestSuite {
    /// Tests successful image generation using DALL-E 2
    /// Verifies that the client can generate images and return valid base64-encoded results
    /// - Throws: Any errors that occur during the test execution, including:
    ///   - Client initialization errors
    ///   - Image generation failures
    ///   - Invalid response formats
    @Test("Generate Image Result Success (dalle2)")
    public func generateImageResultSuccessDalle2() async throws {
        try await withApp { app in
            // Generate an image using DALL-E 2 with specified parameters
            let result = try await generateImage(
                app: app,
                query: .init(
                    model: .dall_e_2,
                    prompt: defaultPrompt,
                    totalImagesToGenerate: 1,
                    imageSize: ._256
                )
            )

            // Decode the result metadata to verify the image data
            let imagesResult = try JSONDecoder().decode(ImagesResult.self, from: result.metadataJSON)
            let image = imagesResult.data[0]

            // Ensure the generated image base64 string is not nil
            try #require(image.b64Json != nil, "Generated image base64 string should not be nil")
        }
    }

    /// Tests successful image generation using DALL-E 3
    /// Verifies that the client can generate images with DALL-E 3 specific parameters
    /// - Throws: Any errors that occur during the test execution, including:
    ///   - Client initialization errors
    ///   - Image generation failures
    ///   - Invalid response formats
    @Test("Generate Image Result Success (dalle3)")
    public func generateImageResultSuccessDalle3() async throws {
        try await withApp { app in
            // Initialize the image generation client
            let client = ImageGenerationClient(logger: app.logger)

            // Create a query for generating an image using DALL-E 3
            let query: GenerateImageQuery = .init(
                model: .dall_e_3,
                prompt: defaultPrompt,
                totalImagesToGenerate: 1,
                quality: .standard,
                imageSize: ._1024,
                imageStyle: .vivid
            )

            // Generate the image using the client
            let result = try await client.generateImage(query)

            // Decode the result metadata to verify the image data
            let imagesResult = try JSONDecoder().decode(ImagesResult.self, from: result.metadataJSON)
            let image = imagesResult.data[0]

            // Ensure the generated image base64 string is not nil
            try #require(image.b64Json != nil, "Generated image base64 string should not be nil")
        }
    }
}
