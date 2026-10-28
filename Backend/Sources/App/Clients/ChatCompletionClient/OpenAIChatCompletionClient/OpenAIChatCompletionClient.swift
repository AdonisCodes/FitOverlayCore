// OpenAIChatCompletionClient.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import AutomaUtilities
import OpenAI
import Retry
import Vapor

/// Client for interacting with OpenAI's chat completion API
/// Handles authentication, request configuration, and response processing for chat completions
///
/// This struct provides a wrapper around OpenAI's chat completion API, handling:
/// - API authentication and configuration
/// - Request retry logic
/// - Error handling and logging
/// - Metrics tracking
/// - Response processing and validation
internal struct OpenAIChatCompletionClient: ChatCompletionClientBase {
    /// The underlying OpenAI API client used for making API requests
    /// This client handles the low-level communication with OpenAI's services
    private let client: OpenAI

    /// Logger instance for tracking operations and errors
    /// Used throughout the client to log important events, errors, and debugging information
    public let logger: Logger

    /// API key for authenticating with OpenAI services
    /// This key is required for all API requests to OpenAI
    private let apiKey: String

    /// Initializes a new OpenAI chat completion client
    /// - Parameters:
    ///   - logger: Logger instance for tracking operations and debugging
    ///   - timeout: Maximum time to wait for API responses in seconds (default: 180)
    ///   - apiKey: Optional API key override. If nil, reads from environment variables
    /// - Throws: Environment error if API key cannot be retrieved from environment
    public init(logger: Logger, timeout: TimeInterval = 180, apiKey: String? = nil) throws {
        self.apiKey = try apiKey ?? Environment.getOrThrow("OPENAI_API_KEY")
        client = .init(
            configuration: .init(
                token: self.apiKey,
                timeoutInterval: timeout
            )
        )
        self.logger = logger
    }

    /// Creates a chat completion using the OpenAI API
    ///
    /// This method handles the complete lifecycle of a chat completion request:
    /// 1. Configures and sends the request to OpenAI
    /// 2. Implements retry logic for failed requests
    /// 3. Processes and validates the response
    /// 4. Tracks metrics and logs relevant information
    ///
    /// - Parameter query: The chat completion request parameters containing model, prompt, and token settings
    /// - Returns: ChatCompletionResult containing the generated message and response metadata
    /// - Throws: ChatCompletionClientError for various failure scenarios:
    ///   - completionError: General API or processing failures
    ///   - completionMessageEmpty: When the response contains no message content
    public func createChat(_ query: ChatCompletionContent) async throws -> ChatCompletionResult {
        // Extract required parameters from the query
        let model = query.model
        var result: ChatResult?
        let prompt = query.prompt

        // Attempt to create chat completion with retry logic
        do {
            try await retry(
                maxAttempts: 3
            ) {
                guard
                    let message: ChatQuery.ChatCompletionMessageParam = .init(role: .system, content: prompt)
                else {
                    logger.error(
                        "Could not create chat completion messages array, messages is nil",
                        metadata: [
                            "to": .string("\(String(describing: Self.self)).\(#function)"),
                            "model": .string(model.rawValue),
                            "query": .string(prompt),
                        ]
                    )
                    throw ChatCompletionClientError.requestMessageNil
                }

                let messages = [message]
                result = try await client.chats(
                    query: .init(
                        messages: messages,
                        model: model.rawValue,
                        maxCompletionTokens: query.maxCompletionTokens
                    )
                )
            }
        } catch {
            // Handle and log API request failures
            BackendMetric.chatCompletionServiceCall(platform: .openai, model: model, status: .fail).increment()
            logger.error(
                "Failed to generate chat completion, error: \(error)",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "model": .string(model.rawValue),
                    "query": .string(prompt),
                ]
            )
            throw ChatCompletionClientError.completionError
        }

        // Validate the result exists
        guard
            let result
        else {
            throw ChatCompletionClientError.completionError
        }

        // Validate usage information is available
        guard
            let usage = result.usage
        else {
            logger.error(
                "Unable to get usage from chat completion result.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                ]
            )
            throw ChatCompletionClientError.completionError
        }

        // Log usage information
        logger.info(
            "OpenAI chat completions result usage metadata",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "usage": .string("\(usage)"),
            ]
        )

        // Extract and validate message content
        guard let message = result.choices.first?.message.content else {
            BackendMetric.chatCompletionServiceCall(platform: .openai, model: model, status: .fail).increment()
            logger.error(
                "Failed to generate chat completion, message empty",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "model": .string(model.rawValue),
                    "query": .string(prompt),
                    "resultObject": .string(result.object),
                ]
            )
            throw ChatCompletionClientError.completionMessageEmpty
        }

        // Track successful completion and log final metadata
        BackendMetric.chatCompletionServiceCall(platform: .openai, model: model, status: .success).increment()
        let metadata = try JSONEncoder().encode(result)
        logger.info(
            "OpenAI chat completions result full metadata",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "metadata": .string(String(reflecting: result)),
            ]
        )

        return .init(message: message, metadata: metadata)
    }
}
