// SNSService.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import AutomaUtilities
import DataTypes
import Foundation
import SotoSNS
import Vapor

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

internal class SNSService {
    private let messageService: MessageService
    private let clientAuth: AWSClient

    /// Initialize new SNSService instance
    public init() throws {
        messageService = MessageService()
        clientAuth = try AWSClient(
            credentialProvider: .static(
                accessKeyId: Environment.getOrThrow("AWS_ACCESS_KEY_ID"),
                secretAccessKey: Environment.getOrThrow("AWS_SECRET_ACCESS_KEY")
            )
        )
    }

    /// Send an SMS to a phone number
    /// - Parameters:
    ///   - phoneNumber: Number to send SMS to
    ///   - message: Message to send as SMS to number
    ///   - logger: Logger used for creating logs
    ///
    /// - Throws: An error creating an SNS client, publishing an SMS, logging send sms event \
    /// or extracting message identifier
    /// - Returns: Message identifier as a string
    public func sendSmS(
        to phoneNumber: String,
        message: String,
        logger: Logger
    ) async throws -> String {
        do {
            let snsClient = try createSNSClient()
            let output = try await snsClient.publish(.init(message: message, phoneNumber: phoneNumber))

            try logSmsSentEvent(to: phoneNumber, message: message, logger: logger)
            return try extractMessageId(from: output, phoneNumber: phoneNumber, message: message, logger: logger)
        } catch {
            handleSmsError(error, to: phoneNumber, message: message, logger: logger)
            throw error
        }
    }

    private func createSNSClient() throws -> SNS {
        let region = try Environment.getOrThrow("AWS_DEFAULT_REGION")
        return SNS(client: clientAuth, region: .other(region))
    }

    private func extractMessageId(
        from output: SNS.PublishResponse,
        phoneNumber: String,
        message: String,
        logger: Logger
    ) throws -> String {
        guard let messageId = output.messageId else {
            logger.error("Failed to send message to user", metadata: [
                "to": .string("MessageService.sendSmS"),
                "phoneNumber": .string(phoneNumber),
                "message": .string(message),
            ])
            throw GenericErrors.smsMessageFailed
        }

        logger.info("Sent SMS message to user", metadata: [
            "to": .string("MessageService.sendSmS"),
            "messageId": .string(messageId),
            "phoneNumber": .string(phoneNumber),
            "message": .string(message),
            "sequenceNumber": .string(output.sequenceNumber ?? "")
        ])
        BackendMetric.totalTextMessagesSent.increment()

        return messageId
    }

    private func handleSmsError(
        _ error: Error,
        to phoneNumber: String,
        message: String,
        logger: Logger
    ) {
        logger.error("Failed to send message", metadata: [
            "to": .string("MessageService.sendSmS"),
            "phoneNumber": .string(phoneNumber),
            "message": .string(message),
            "error": .string(error.localizedDescription)
        ])
        BackendMetric.totalTextMessagesSentFailed.increment()
    }

    private func logSmsSentEvent(to phoneNumber: String, message: String, logger: Logger) throws {
        try messageService.sendDiscordWebhookAppEvent(
            input: "random -> \(phoneNumber)",
            event: "sending message: `\(message)`",
            logger: logger
        )
    }

    deinit {
        try! clientAuth.syncShutdown()
    }
}
