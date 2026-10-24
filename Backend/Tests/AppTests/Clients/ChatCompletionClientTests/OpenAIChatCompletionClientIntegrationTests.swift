// OpenAIChatCompletionClientIntegrationTests.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

@testable import App
import Fluent
import OpenAI
import Testing
import VaporTesting

/// Tests for the OpenAI Chat Completion Client implementation
/// These tests verify the functionality of chat completion generation using OpenAI models
@Suite("OpenAIChatCompletionClientIntegrationTests")
internal struct OpenAIChatCompletionClientIntegrationTests: ChatCompletionClientTestSuite {
    /// Tests successful chat completion generation using OpenAI's GPT-4o model
    /// Verifies that the client can generate valid chat completions and return proper metadata
    ///
    /// This test:
    /// - Creates a chat completion with the default prompt
    /// - Validates the response contains a meaningful message
    /// - Confirms the metadata contains the correct model information
    ///
    /// - Throws: Any errors that occur during the test execution, including:
    ///   - Client initialization errors
    ///   - Network errors
    ///   - Invalid response formats
    @Test("Generate Chat Completion Result Success")
    public func generateChatCompletionResultSuccess() async throws {
        try await withApp { app in
            let model = ChatCompletionModel.gpt4o

            let result = try await createChat(app: app, query: .init(model: model, prompt: defaultPrompt))
            let metadata = try JSONDecoder().decode(ChatResult.self, from: result.metadata)

            #expect(result.message.count > 5, "Generated message should have more than 5 characters")
            #expect(result.message.count < maxCompletionTokens * 4, "Message should not be bigger than max tokens")
            #expect(metadata.model.contains(model.rawValue), "Model should be \(model.rawValue)")
        }
    }
}
