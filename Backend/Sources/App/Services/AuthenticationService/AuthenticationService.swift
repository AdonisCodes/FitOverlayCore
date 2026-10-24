// AuthenticationService.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import AutomaUtilities
import DataTypes
import Fluent
import JWT
import Temporal
import Vapor

internal struct RootAuthenticationService: AuthenticationService {
    private var config: any AuthenticationServiceConfig
    internal let helper: AuthenticationServiceHelper
    internal let messageService = MessageService()

    /// Initializes authentication service
    public init(_ config: RootAuthenticationServiceConfig) {
        self.config = config
        helper = .init(.init(writeDb: config.writeDb, readDb: config.readDb, logger: config.logger))
    }

    /// Register a user
    public func register(
        _ payload: UserRegistrationPayload,
        temporalClient: TemporalClient
    ) async throws -> AuthenticationTokensPayloadDTO {
        var registrator = UserRegistrationService(.init(
            writeDb: config.writeDb,
            readDb: config.readDb,
            logger: config.logger,
            temporalClient: temporalClient,
            payload: payload
        ))
        return try await registrator.register()
    }

    /// Login User
    public func login(_ payload: UserLoginPayload) async throws -> AuthenticationTokensPayloadDTO {
        let loginService = UserLoginService(.init(
            writeDb: config.writeDb,
            readDb: config.readDb,
            logger: config.logger,
            payload: payload
        ))
        return try await loginService.login()
    }

    /// Send authentication code
    public func sendAuthCode(phoneNumber: String,
                             temporalClient: TemporalClient) async throws -> AuthenticationCodeResponseDTO
    {
        let code = RandomService.randomCode()
        logAuthCodeAttempt(phoneNumber: phoneNumber, code: code)

        if let timeout = try await existingCodeTimeout(phoneNumber: phoneNumber) {
            return .init(success: timeout == 0, timeout: timeout)
        }

        let codeModelId = UUID()

        return try await sendOrHandleAuthCode(
            phoneNumber: phoneNumber,
            code: code,
            codeModelId: codeModelId,
            temporalClient: temporalClient
        )
    }

    /// Refresh Token
    public func refreshToken(userId: UUID, signer: Request.JWT) async throws -> String {
        do {
            try sendRefreshEvent(userId: userId.uuidString)
            logRefresh(userId: userId.uuidString)

            return try await helper.resetAccessToken(
                .init(
                    userId: userId, expiresIn: 86_400, subject: .access, signer: signer
                )
            )
        } catch {
            BackendMetric.totalFailedTokensRefreshed.increment()
            throw error
        }
    }

    /// Logs user out
    public func logout(userId: UUID) async throws {
        try sendLogoutEvent(userId: userId)
        logLogout(userId: userId)

        let concurrencySafeHelper: AuthenticationServiceHelper = .init(.init(
            writeDb: config.writeDb,
            readDb: config.readDb,
            logger: config.logger
        ))

        async let deleteRefresh: () = concurrencySafeHelper.deleteOldTokens(.init(userId: userId, subject: .refresh))
        async let deleteAccess: () = concurrencySafeHelper.deleteOldTokens(.init(userId: userId, subject: .access))

        _ = try await (deleteRefresh, deleteAccess)
    }

    /// CHecks if a user exists based on phone number
    public func doesUserExist(phoneNumber: String) async throws -> Bool {
        do {
            let exists = try await checkUserExists(phoneNumber: phoneNumber)
            if exists {
                BackendMetric.totalUsersAlreadyExists.increment()
            }
            return exists
        } catch {
            logUserExistenceError(phoneNumber: phoneNumber, error: error)
            throw Abort(.internalServerError)
        }
    }

    // MARK: - Private Helpers

    private func logAuthCodeAttempt(phoneNumber: String, code: String) {
        config.logger.info(
            "Sending verification code to user",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "phoneNumber": .string(phoneNumber),
                "code": .string(code),
            ]
        )
    }

    private func existingCodeTimeout(phoneNumber: String) async throws -> TimeInterval? {
        let distance = try await helper.getCodeRateLimit()
        let dateToCheck = Date()

        guard let recentCode = try await AuthenticationCodeModel
            .query(on: config.readDb)
            .filter(\.$createdAt > dateToCheck.addingTimeInterval(-distance))
            .filter(\.$phoneNumber == phoneNumber)
            .first()
        else {
            return nil
        }

        return distance - (recentCode.createdAt?.distance(to: dateToCheck) ?? distance)
    }

    private func sendOrHandleAuthCode(
        phoneNumber: String,
        code: String,
        codeModelId: UUID,
        temporalClient: TemporalClient,
    ) async throws -> AuthenticationCodeResponseDTO {
        do {
            return try await helper.sendAuthCode(
                .init(
                    code: code,
                    phoneNumber: phoneNumber,
                    codeModelId: codeModelId
                ),
                temporalClient: temporalClient
            )
        } catch let error as GenericErrors {
            await helper.sendTelemetryDataOnAuthCodeSendFail(
                code: code,
                phoneNumber: phoneNumber,
                codeModelId: codeModelId,
                error: error
            )
            throw error
        } catch {
            await helper.sendTelemetryDataOnAuthCodeSendFail(
                code: code,
                phoneNumber: phoneNumber,
                codeModelId: codeModelId,
                error: error
            )
            throw GenericErrors.unknownError
        }
    }

    private func sendRefreshEvent(userId: String) throws {
        try messageService.sendDiscordWebhookAppEvent(
            input: userId,
            event: "is refreshing their access token",
            logger: config.logger
        )
    }

    private func logRefresh(userId: String) {
        config.logger.info(
            "Refreshing user access token",
            metadata: [
                "to": .string("AuthenticationService.refreshToken"),
                "userId": .string(userId),
            ]
        )
    }

    private func sendLogoutEvent(userId: UUID) throws {
        try messageService.sendDiscordWebhookAppEvent(
            input: userId.uuidString,
            event: "is logging out",
            logger: config.logger
        )
    }

    private func logLogout(userId: UUID) {
        config.logger.info(
            "Logging user out",
            metadata: [
                "to": .string("AuthenticationService.refreshToken"),
                "userId": .string(userId.uuidString),
            ]
        )
    }

    private func checkUserExists(phoneNumber: String) async throws -> Bool {
        try await UserModel
            .query(on: config.readDb)
            .filter(\.$phoneNumber == phoneNumber)
            .count() > 0
    }

    private func logUserExistenceError(phoneNumber: String, error: Error) {
        config.logger.error(
            "Error checking if user exists.",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "phoneNumber": .string(phoneNumber),
                "error": .string("\(error.localizedDescription)"),
            ]
        )
    }
}

internal protocol AuthenticationService {
    /// Helper
    var helper: AuthenticationServiceHelper { get }
    /// Message Service
    var messageService: MessageService { get }
}

internal protocol AuthenticationServiceConfig {
    /// Db w/ write access
    var writeDb: Database { get }
    /// Db w/ readonly access
    var readDb: Database { get }
    /// Logger
    var logger: Logger { get }
}

internal struct RootAuthenticationServiceConfig: AuthenticationServiceConfig {
    /// Db w/ write access
    public let writeDb: Database
    /// Db w/ readonly access
    public let readDb: Database
    /// Logger
    public let logger: Logger
}
