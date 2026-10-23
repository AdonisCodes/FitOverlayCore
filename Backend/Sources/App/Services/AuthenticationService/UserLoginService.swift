// UserLoginService.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import DataTypes
import Fluent
import JWT
import Vapor

internal struct UserLoginService: AuthenticationService {
    internal var helper: AuthenticationServiceHelper
    private let config: UserLoginConfig
    internal var eventService = EventNotificationService()

    /// Initializes user login service
    public init(_ config: UserLoginConfig) {
        self.config = config
        helper = .init(.init(writeDb: config.writeDb, readDb: config.readDb, logger: config.logger))
    }

    public func login() async throws -> AuthenticationTokensPayloadDTO {
        try await validateAuthCode()

        guard let user = try await findUser() else {
            logMissingUserError()
            throw GenericErrors.userNotFound
        }

        return try await completeLogin(for: user)
    }

    // MARK: - Private Helpers

    private func validateAuthCode() async throws {
        try await helper.validateAndDeleteCode(config.payload.authCodePayload)
    }

    private func findUser() async throws -> UserModel? {
        try await UserModel
            .query(on: config.readDb)
            .filter(\.$phoneNumber == config.payload.authCodePayload.phoneNumber)
            .first()
    }

    private func completeLogin(for user: UserModel) async throws -> AuthenticationTokensPayloadDTO {
        let userId: UUID
        do {
            userId = try user.requireID()
        } catch {
            config.logger.error("User model has no ID")
            throw GenericErrors.userNotFound
        }

        try sendLoginEvent(for: user)
        logUserLogin(userId: userId.uuidString, username: user.username)

        return try await helper.createAuthenticationTokensPayload(.init(userId: userId, signer: config.payload.signer))
    }

    private func sendLoginEvent(for user: UserModel) throws {
        try eventService.sendAppEvent(
            input: "\(config.payload.authCodePayload.phoneNumber) - \(user.username)",
            event: "logging in with code: `\(config.payload.authCodePayload.code)`",
            logger: config.logger
        )
    }

    private func logUserLogin(userId: String, username: String) {
        config.logger.info(
            "Logging in user",
            metadata: [
                "to": .string("AuthenticationService.login"),
                "userId": .string(userId),
                "username": .string(username),
            ]
        )
    }

    private func logMissingUserError() {
        config.logger.error(
            "Can't login non-existent user",
            metadata: [
                "to": .string("AuthenticationService.login"),
                "config": .string(String(describing: config.payload)),
            ]
        )
    }
}

internal struct UserLoginPayload {
    /// Payload for sending auth token
    public let authCodePayload: AuthPhoneCodePayloadDTO
    /// Signer to create JWT tokens
    public let signer: Request.JWT
}

internal struct UserLoginConfig: AuthenticationServiceConfig {
    /// Db w/ write access
    public let writeDb: Database
    /// Db w/ readonly access
    public let readDb: Database
    /// Logger
    public let logger: Logger
    /// Payload to log user in
    public let payload: UserLoginPayload
}
