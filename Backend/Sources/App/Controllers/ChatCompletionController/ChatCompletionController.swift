// ChatCompletionController.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent
import OpenAI
import Vapor

/// Controller for handling chat completion requests.
internal struct ChatCompletionController: RouteCollection {
    /// Registers routes for chat completion operations.
    /// - Parameter routes: The routes builder to register routes on.
    public func boot(routes: RoutesBuilder) throws {
        let chatCompletionRoute = routes.grouped("ChatCompletion").grouped(
            TestControllerMiddleware()
        )

        chatCompletionRoute.post("openai", use: openai)
    }

    /// Handles chat completion requests using OpenAI.
    /// - Parameter req: The request containing chat completion content.
    /// - Returns: A string containing the chat completion result.
    /// - Throws: An error if the request or chat completion fails.
    @Sendable
    public func openai(req: Request) async throws -> String {
        let openaiClient = try OpenAIChatCompletionClient(logger: req.logger)
        let query = try req.content.decode(ChatCompletionContent.self)
        let result = try await openaiClient.createChat(query)

        return result.message
    }
}
