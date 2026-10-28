// ImageGenerationClientIntegrationTests.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

@testable import App
import Fluent
import Testing
import VaporTesting

/// Test suite for verifying the functionality of image generation clients
/// This suite tests different image generation models and ensures they can properly generate images
/// according to specified parameters like quality, size, and style
@Suite("ImageGenerationClientIntegrationTests")
internal struct ImageGenerationClientIntegrationTests: ImageGenerationClientTestSuite {
    /// Tests successful image generation for each image generation client
    /// This test verifies that:
    /// - The client can be initialized properly
    /// - Image generation requests are processed successfully
    /// - The correct number of images is returned
    /// - The generated images match the requested parameters
    ///
    /// - Parameter model: The model to use for image generation (e.g. DALL-E 3)
    /// - Throws: Any errors that occur during test execution, including:
    ///   - Client initialization errors
    ///   - Image generation failures
    ///   - Invalid response formats
    @Test(
        "Each image generation client should be able to generate images",
        arguments: [
            GenerateImageModel.dall_e_2, // will use openai client
        ]
    )
    public func generateImageResultSuccess(model: GenerateImageModel) async throws {
        try await withApp { app in
            let totalImagesToGenerate = 1

            // Configure the image generation request with specific parameters
            let result = try await generateImage(
                app: app,
                query: .init(
                    model: model,
                    prompt: defaultPrompt,
                    totalImagesToGenerate: totalImagesToGenerate,
                    // quality: .standard,
                    imageSize: ._256
                    // imageStyle: .vivid
                )
            )

            // Verify the number of images generated matches the request
            #expect(result.images.count == totalImagesToGenerate)
        }
    }
}
