// AuthCodeDeliveryService.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

/// Delivers verification codes to users.
/// The reference implementation dispatched a Temporal workflow that sent an SMS via SNS.
/// FitOverlay ships a provider-agnostic protocol with a logging stub so the auth flow is
/// fully functional in development; plug in an SMS/email provider for production.
internal protocol AuthCodeDeliveryService: Sendable {
    /// Sends a verification code to the given phone number.
    /// - Parameters:
    ///   - code: The verification code to deliver
    ///   - phoneNumber: The destination phone number (E.164)
    func send(code: String, toPhoneNumber phoneNumber: String) async throws
}

/// Development/default delivery that only logs the code.
/// TODO: Replace with an SMS (SNS/Twilio) or email provider before launch.
internal struct LoggingAuthCodeDeliveryService: AuthCodeDeliveryService {
    /// Logger used to surface the code during development
    public let logger: Logger

    /// Initializes the logging delivery service
    public init(logger: Logger) {
        self.logger = logger
    }

    /// Logs the verification code instead of sending it.
    public func send(code: String, toPhoneNumber phoneNumber: String) async throws {
        logger.notice(
            "Verification code (stub delivery — not actually sent)",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "phoneNumber": .string(phoneNumber),
                "code": .string(code),
            ]
        )
    }
}

/// Crafts the user-facing verification message.
internal enum MessageFormatterService {
    /// Returns the text message body containing the verification code.
    public static func craftVerificationCodeMessage(code: String) -> String {
        "Your FitOverlay verification code is: \(code)"
    }
}
