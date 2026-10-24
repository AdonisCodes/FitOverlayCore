// TemporalWorkerCommand.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Temporal
import Vapor

struct TemporalWorkerCommand: AsyncCommand {
    struct Signature: CommandSignature {}

    var help: String {
        "startup temporal worker"
    }

    func run(using context: CommandContext, signature _: Signature) async throws {
        try await AppConfigurator(
            app: context.application,
            config: .init(
                shouldSetupAPI: false,
                metricsPort: 6_835
            )
        ).configure()
        try await setupTemporal(logger: context.application.logger)
    }

    private func setupTemporal(logger: Logger) async throws {
        logSetupTemporalWorkerStarted(logger)
        let worker = try getTemporalWorker(
            hostname: TemporalClient.getServerHostnameFromEnv()
        )
        logSetupTemporalWorkerConfigured(logger)
        do {
            try await worker.run()
        } catch {
            // Capture the current stack trace
            let stackTrace = Thread.callStackSymbols.joined(separator: "\n")

            logger.info(
                "Error occurred while running tmeporal worker",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string(error.localizedDescription),
                    "stackTrace": .string(stackTrace),
                ]
            )

            throw error
        }
    }

    private func logSetupTemporalWorkerStarted(_ logger: Logger) {
        logger.info(
            "Setting up temporal worker started.",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
            ]
        )
    }

    private func getTemporalWorker(hostname temporalServerHostname: String) throws -> TemporalWorker {
        try TemporalWorker(
            configuration: .init(
                namespace: "default",
                taskQueue: "default-queue",
                instrumentation: .init(serverHostname: temporalServerHostname)
            ),
            target: .dns(host: temporalServerHostname, port: 7_233),
            transportSecurity: .plaintext,
            activities: [
                ProfilePictureActivities().activities.createPicture,
                TransactionalMessageActivities().activities.sendMessage
            ],
            workflows: [CreateProfilePictureWorkflow.self, SendTransactionalMessageWorkflow.self],
            logger: Logger(label: "temporal-worker")
        )
    }

    private func logSetupTemporalWorkerConfigured(_ logger: Logger) {
        logger.info(
            "Configured temporal worker instance.",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
            ]
        )
    }
}
