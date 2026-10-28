// ChatCompletionClient.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

/// Protocol defining the interface for chat completion services
/// Implementations handle the specifics of interacting with different AI platforms
public protocol ChatCompletionClientBase {
    /// Logger instance for tracking operations and errors
    var logger: Logger { get }

    /// Creates a chat completion using the specified query parameters
    /// - Parameter query: The chat completion request parameters
    /// - Returns: The generated chat completion result
    /// - Throws: Errors that occur during the chat completion process
    func createChat(_ query: ChatCompletionContent) async throws -> ChatCompletionResult
}

/// Structure representing the content of a chat completion request
/// Contains all necessary parameters to generate a chat completion
public struct ChatCompletionContent: Content {
    /// The AI model to use for generating the completion
    public let model: ChatCompletionModel

    /// The prompt text to send to the AI model
    public let prompt: String

    /// The maximum number of tokens to generate in the completion
    public let maxCompletionTokens: Int?

    public init(model: ChatCompletionModel, prompt: String, maxCompletionTokens: Int? = nil) {
        self.model = model
        self.prompt = prompt
        self.maxCompletionTokens = maxCompletionTokens
    }
}

/// Enumeration of supported chat completion models
/// Each case represents a specific AI model with its raw string value
public enum ChatCompletionModel: String, Codable, Sendable {
    /// https: // platform.openai.com/docs/models/gpt-4o
    case gpt4o = "gpt-4o"

    /// https://platform.openai.com/docs/models/gpt-4o-mini
    case gpt4omini = "gpt-4o-mini"

    /// https://platform.openai.com/docs/models/o1
    case gpto1 = "o1"

    /// Returns the appropriate platform-specific client for the selected model
    /// - Parameter logger: Logger instance to be passed to the client
    /// - Returns: A client conforming to the ChatCompletion protocol
    /// - Throws: Errors from client initialization
    public func getPlatformClient(logger: Logger) throws -> any ChatCompletionClientBase {
        switch self {
        case .gpt4o, .gpt4omini, .gpto1:
            try OpenAIChatCompletionClient(logger: logger)
        }
    }
}

/// Enumeration of supported chat completion platforms
/// Identifies the AI service provider
public enum ChatCompletionPlatform: String, Codable {
    /// OpenAI platform (includes GPT models)
    case openai
}

/// Structure representing the result of a chat completion
/// Contains the generated message and any additional metadata
public struct ChatCompletionResult: Content {
    /// The generated text response from the AI model
    public let message: String

    /// Additional metadata about the completion
    public let metadata: Data
}

/// Client for handling chat completion requests across different AI platforms.
/// Delegates requests to the appropriate platform-specific client based on the model.
///
/// This struct implements the `ChatCompletion` protocol and serves as a facade for various
/// AI platform-specific chat completion implementations. It dynamically selects and uses
/// the appropriate client based on the requested model.
///
/// Usage example:
/// ```swift
/// let client = ChatCompletionClient(logger: logger)
/// let result = try await client.createChat(query)
/// ```
public struct ChatCompletionClient: ChatCompletionClientBase {
    /// Logger instance for tracking operations and errors.
    /// This logger is passed to platform-specific clients for consistent logging across the system.
    ///
    /// The logger is used to:
    /// - Track API calls and their responses
    /// - Log errors and exceptions
    /// - Monitor performance metrics
    public var logger: Logging.Logger

    /// Creates a chat completion using the appropriate platform client.
    ///
    /// This method performs the following steps:
    /// 1. Determines the appropriate platform client based on the model
    /// 2. Initializes the platform-specific client
    /// 3. Delegates the chat completion request to the selected client
    ///
    /// - Parameter query: The chat completion request parameters including model, prompt and other settings.
    ///                   This contains all necessary information to generate the completion.
    /// - Returns: The generated chat completion result containing the AI's response and any additional metadata.
    /// - Throws: Errors that may occur during:
    ///          - Platform client initialization
    ///          - Invalid model selection
    ///          - Network communication
    ///          - Chat completion generation
    public func createChat(_ query: ChatCompletionContent) async throws -> ChatCompletionResult {
        // Get the appropriate platform client based on the requested model
        let client = try query.model.getPlatformClient(logger: logger)

        // Delegate the chat completion request to the platform-specific client
        return try await client.createChat(query)
    }
}
