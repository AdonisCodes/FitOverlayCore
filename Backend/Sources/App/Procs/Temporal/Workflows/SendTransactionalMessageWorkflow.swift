// SendTransactionalMessageWorkflow.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Temporal
import Vapor

@Workflow
internal final class SendTransactionalMessageWorkflow {
    func run(input: SendTransactionalMessageActivityInput) async throws {
        do {
            try await Workflow.executeActivity(
                TransactionalMessageActivities.Activities.SendMessage.self,
                options: ActivityOptions(startToCloseTimeout: .seconds(30)),
                input: input
            )
        } catch {
            // Capture the current stack trace
            let stackTrace = Thread.callStackSymbols.joined(separator: "\n")

            let logger = Logger(label: "send-transactional-message-workflow")
            logger.info(
                "Error occurred while processing workflow",
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
