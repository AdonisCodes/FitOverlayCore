// ImageGenerationClientTestSuite.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

@testable import App
import OpenAI
import VaporTesting

/// Protocol defining common functionality for image generation client test suites
/// This protocol provides shared test utilities and default values used across different
/// image generation client implementations
internal protocol ImageGenerationClientTestSuite {
    /// The default prompt to use for image generation tests
    /// This prompt should generate safe, consistent test images
    var defaultPrompt: String { get }
}

extension ImageGenerationClientTestSuite {
    /// Default implementation of the prompt used for image generation
    /// Provides a consistent, family-friendly prompt that works well with most image generation models
    public var defaultPrompt: String {
        "A fluffy golden retriever puppy playing in a sunny meadow filled with colorful wildflowers."
    }

    /// Helper function to create and manage a test application instance
    /// Creates a test application, runs the provided test closure, and ensures proper cleanup
    ///
    /// - Parameter test: The test closure to execute with the application instance
    /// - Throws: Any errors that occur during test execution, including:
    ///   - Application initialization errors
    ///   - Test execution errors
    ///   - Shutdown errors
    private func withApp(test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try await test(app)
        } catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    /// Default implementation of the image generation function
    /// Uses the ImageGenerationClient to generate an image based on the provided query
    ///
    /// - Parameter app: The Vapor application instance
    /// - Parameter query: The image generation query parameters
    /// - Returns: The generated image result
    /// - Throws: Any errors that occur during the image generation process
    public func generateImage(
        app: Application,
        query: GenerateImageQuery
    ) async throws -> GenerateImageResult {
        let client = ImageGenerationClient(logger: app.logger)
        return try await client.generateImage(query)
    }
}
