// TransactionalMessageActivities.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Foundation
import Temporal
import Vapor

/// Input payload for send transactional message activity.
internal struct SendTransactionalMessageActivityInput: Sendable, Codable {
    /// The content of the message.
    public let content: String
    /// The phone number to send the message to.
    public let toPhoneNumber: String
}

/// Activites for sending a transactional message.
@ActivityContainer
internal struct TransactionalMessageActivities {
    /// Activity for sending a transactional message.
    /// - Parameters:
    ///   - input: The input for sending a transactional message.
    /// - Throws: Throws an error if the message sending fails.
    @Sendable @Activity
    public func sendMessage(input: SendTransactionalMessageActivityInput) async throws {
        let logger = Logger(label: "temporal")
        let snsService = try SNSService()

        // Send the SMS message
        do {
            _ = try await snsService
                .sendSmS(
                    to: input.toPhoneNumber,
                    message: input.content,
                    logger: logger
                )
        } catch {
            // Capture the current stack trace
            let stackTrace = Thread.callStackSymbols.joined(separator: "\n")

            logger.info(
                "Error occurred while processing activity",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string(error.localizedDescription),
                    "input": .string("\(input.content)"),
                    "stackTrace": .string(stackTrace),
                ]
            )
        }
    }
}
