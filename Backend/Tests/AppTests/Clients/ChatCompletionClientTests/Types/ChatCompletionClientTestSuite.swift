// ChatCompletionClientTestSuite.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

@testable import App
import VaporTesting

/// Protocol defining common functionality for chat completion client test suites
/// This protocol provides shared test utilities and methods used across different
/// chat completion client implementations
internal protocol ChatCompletionClientTestSuite: MinimalVaporApplicationTestSuite {
    /// The default prompt to use for chat completion tests
    var defaultPrompt: String { get }

    /// The maximum number of tokens allowed in a chat completion
    var maxCompletionTokens: Int { get }

    /// Creates a chat completion using the configured client
    /// - Parameter query: The chat completion request parameters
    /// - Returns: The generated chat completion result
    /// - Throws: Any errors that occur during the chat completion process
    func createChat(app: Application, query: ChatCompletionContent) async throws
        -> ChatCompletionResult
}

extension ChatCompletionClientTestSuite {
    /// The default prompt to use for chat completion tests
    public var defaultPrompt: String {
        "Hello, world!"
    }

    /// The maximum number of tokens allowed in a chat completion
    public var maxCompletionTokens: Int {
        100
    }

    /// Default implementation for creating a chat completion
    /// Note: This implementation requires the 'app' parameter to be in scope
    ///
    /// - Parameter query: The chat completion request parameters
    /// - Returns: The generated chat completion result
    /// - Throws: Any errors that occur during the chat completion process, including:
    ///   - Client initialization errors
    ///   - Network errors
    ///   - Invalid response formats
    public func createChat(
        app: Application,
        query: ChatCompletionContent
    ) async throws -> ChatCompletionResult {
        let client = ChatCompletionClient(logger: app.logger)

        let queryWithMaxTokens: ChatCompletionContent = .init(
            model: query.model,
            prompt: query.prompt,
            maxCompletionTokens: maxCompletionTokens
        )

        return try await client.createChat(queryWithMaxTokens)
    }
}
