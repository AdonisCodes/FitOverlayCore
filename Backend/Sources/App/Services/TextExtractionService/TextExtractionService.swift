// TextExtractionService.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent
import SotoTextract
import Vapor

/// Service for extracting text from images.
internal struct TextExtractionService: ~Copyable {
    /// The Textract client for text extraction.
    public let client: Textract
    /// Logger to log messages
    public let logger: Logger

    /// Initializes a new instance of `TextExtractionService`.
    public init(logger: Logger) {
        client = Textract(
            client: .init(),
            region: .useast1
        ) // We don't have it in the `default-region` we set in the env
        self.logger = logger
    }

    /// Extracts text from an image.
    /// - Parameter image: The image data.
    /// - Returns: A `Textract.DetectDocumentTextResponse` containing the extracted text.
    /// - Throws: Throws an error if text extraction fails.
    public func getText(from image: Data) async throws -> Textract.DetectDocumentTextResponse {
        try await client.detectDocumentText(.init(document: .init(
            bytes: .base64(image.base64EncodedString())
        )))
    }

    /// Extracts text from an image and returns it as a simple string.
    /// - Parameter image: The image data.
    /// - Returns: A string containing the extracted text.
    /// - Throws: Throws an error if text extraction fails.
    public func getTextToSimpleString(from image: Data) async throws -> String {
        let response = try await getText(from: image)

        guard
            let blocks = response.blocks
        else {
            logger.error(
                "Response text block is empty.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "response": .string(String(reflecting: response)),
                ]
            )
            throw Abort(.internalServerError)
        }
        return blocks
            .map { $0.text ?? "" }
            .filter(\.isEmpty)
            .joined(separator: " ")
            .trimmingCharacters(in: .init(charactersIn: " "))
    }

    /// Deinitializes the `TextExtractionService` and shuts down the client.
    deinit {
        do {
            try client.client.syncShutdown()
        } catch {}
    }
}
