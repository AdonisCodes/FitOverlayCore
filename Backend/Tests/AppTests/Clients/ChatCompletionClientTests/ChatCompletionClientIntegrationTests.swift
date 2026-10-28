// ChatCompletionClientIntegrationTests.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

@testable import App
import Testing

/// Tests for the Chat Completion Client functionality
/// These tests verify that all chat completion client implementations
/// can successfully generate chat completions with various models
@Suite("ChatCompletionClientIntegrationTests")
internal struct ChatCompletionClientIntegrationTests: ChatCompletionClientTestSuite {
    /// Tests that each chat completion client can successfully create a chat completion
    /// This test is parameterized to run with different models, automatically selecting
    /// the appropriate client implementation based on the model
    ///
    /// - Parameter model: The chat completion model to test
    /// - Throws: Any errors that occur during the test execution, including:
    ///   - Client initialization errors
    ///   - Network errors
    ///   - Invalid response formats
    @Test(
        "Each chat completion client should be able to create a chat completion",
        arguments: [
            ChatCompletionModel.gpt4o, // will use openai client
        ]
    )
    public func createChatCompletionSuccess(model: ChatCompletionModel) async throws {
        try await withApp { app in
            // Create a query with the test model and default prompt
            let query = ChatCompletionContent(model: model, prompt: defaultPrompt)

            // Attempt to generate a chat completion
            let result = try await createChat(app: app, query: query)

            // Verify the result contains a non-empty message
            #expect(!result.message.isEmpty, "Message should not be empty")
            #expect(result.message.count < maxCompletionTokens * 4, "Message should not be bigger than max tokens")

            // Verify the result contains metadata
            #expect(!result.metadata.isEmpty, "Metadata should not be empty")
        }
    }
}
