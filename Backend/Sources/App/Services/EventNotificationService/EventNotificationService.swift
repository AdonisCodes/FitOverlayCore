// EventNotificationService.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

/// Sends application events and alerts to the team.
/// The reference implementation forwarded these to Discord webhooks; FitOverlay keeps the
/// same call sites but currently only logs. Hook up a webhook/chat integration here later.
/// TODO: Forward to a Discord/Slack webhook once one is configured (e.g. `APP_EVENTS_WEBHOOK_URL`).
internal struct EventNotificationService: Sendable {
    /// Initializes the service
    public init() {}

    /// Records an application event (e.g. "user logged in").
    /// - Parameters:
    ///   - input: The subject of the event (user id, phone number, ...)
    ///   - event: A short human-readable description of what happened
    ///   - logger: Logger used to record the event
    public func sendAppEvent(input: String, event: String, logger: Logger) throws {
        logger.info(
            "App event",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "input": .string(input),
                "event": .string(event),
            ]
        )
    }

    /// Records an alert for an unexpected error.
    /// - Parameters:
    ///   - alertTitle: A short title describing the alert
    ///   - error: The error that triggered the alert
    ///   - logger: Logger used to record the alert
    public func sendAlert(alertTitle: String, error: Error, logger: Logger) throws {
        logger.critical(
            "App alert",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "title": .string(alertTitle),
                "error": .string(error.localizedDescription),
            ]
        )
    }
}
