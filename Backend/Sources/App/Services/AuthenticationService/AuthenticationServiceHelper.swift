/// AuthenticationServiceHelper.swift
/// Copyright (c) 2026 FitOverlay
/// All source code and related assets are the property of FitOverlay.
/// All rights reserved.

import DataTypes
import Fluent
import JWT
import Vapor

internal actor AuthenticationServiceHelper {
    private let config: AuthenticationServiceHelperConfig
    private let eventService = EventNotificationService()

    /// Authentication Service Helpers
    public init(_ config: AuthenticationServiceHelperConfig) {
        self.config = config
    }

    /// Validates and deletes an authentication code for a given phone number and code.
    public func validateAndDeleteCode(_ payload: AuthPhoneCodePayloadDTO) async throws {
        let validator = AuthenticationCodeValidator(
            .init(
                writeDb: config.writeDb, readDb: config.readDb, logger: config.logger, payload: payload
            )
        )
        try await validator.validateAndDeleteCode()
    }

    /// Resets and returns a new access token for a user.
    public func resetAccessToken(_ payload: ResetAccessCodePayload) async throws -> String {
        try await AccessTokenResetter(.init(
            writeDb: config.writeDb,
            readDb: config.readDb,
            logger: config.logger,
            payload: payload
        ))
        .reset()
    }

    /// Deletes old access tokens for a user and subject.
    public func deleteOldTokens(_ payload: DeleteOldAccessTokensPayload) async throws {
        try await OldAccessTokenDeleter(
            .init(
                writeDb: config.writeDb,
                readDb: config.readDb,
                logger: config.logger,
                payload: payload
            )
        ).deleteOldTokens()
    }

    /// Creates a new set of access and refresh tokens for a user.
    public func createAuthenticationTokensPayload(_ payload: CreateAuthenticationTokensPayload) async throws
        -> AuthenticationTokensPayloadDTO
    {
        try await AuthenticationTokensPayloadCreator(.init(
            writeDb: config.writeDb,
            readDb: config.readDb,
            logger: config.logger,
            payload: payload
        )).create()
    }

    /// Returns the authentication code rate limit as a `Double`.
    public func getCodeRateLimit() throws -> Double {
        try castCodeRateLimitToNumber(getRateLimitString())
    }

    /// Sends a verification code to the given phone number and returns the result.
    public func sendAuthCode(
        _ payload: SendAuthCodePayload,
        codeDelivery: any AuthCodeDeliveryService
    ) async throws -> AuthenticationCodeResponseDTO {
        try await AuthCodeSender(.init(
            writeDb: config.writeDb,
            readDb: config.writeDb,
            logger: config.logger,
            codeDelivery: codeDelivery,
            payload: payload
        )).send()
    }

    /// Reports telemetry if an authentication token didn't send
    public func sendTelemetryDataOnAuthCodeSendFail(
        code: String,
        phoneNumber: String,
        codeModelId: UUID,
        error: any Error
    ) {
        BackendMetric.totalFailedVerificationCodesSent.increment()
        config.logger.error(
            "Couldn't send verification code to user",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "phoneNumber": .string(phoneNumber),
                "code": .string(code),
                "codeId": .string(codeModelId.uuidString),
                "error": .string(error.localizedDescription),
            ]
        )
    }

    private func getRateLimitString() throws -> String {
        try Environment.getOrThrow("AUTHENTICATION_CODE_DISTANCE")
    }

    private func castCodeRateLimitToNumber(_ rateLimitString: String) throws -> Double {
        guard
            let rateLimitNumber = Double(rateLimitString)
        else {
            logCodeRateLimitNotCasted(rateLimit: rateLimitString)
            throw Abort(.internalServerError)
        }
        return rateLimitNumber
    }

    private func logCodeRateLimitNotCasted(rateLimit: String) {
        config.logger.error(
            "Could not convert AUTHENTICATION_CODE_DISTANCE raw value to Double.",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "distance_raw_value": .string(rateLimit),
            ]
        )
    }
}

internal struct AuthenticationServiceHelperConfig: AuthenticationServiceConfig {
    /// Db Connection w/ Write access
    public let writeDb: Database
    /// Db Connection w/ Read-Only access
    public let readDb: Database
    /// Logger
    public let logger: Logger
}

internal struct AuthenticationCodeValidator {
    private let config: AuthenticationCodeValidatorConfig
    private let eventService = EventNotificationService()

    /// Initializes Authentication Code Validation
    public init(_ config: AuthenticationCodeValidatorConfig) {
        self.config = config
    }

    /// Validates & Deletes Verification code
    public func validateAndDeleteCode() async throws {
        try sendTelemetryDataOnValidateAndDeleteCodeAttempt()
        try await getAndValidateCode().delete(on: config.writeDb)
    }

    private func sendTelemetryDataOnValidateAndDeleteCodeAttempt() throws {
        try eventService.sendAppEvent(
            input: config.payload.phoneNumber,
            event: "submitted authentication code to validate `\(config.payload.code)`",
            logger: config.logger
        )
    }

    private func getAndValidateCode() async throws
        -> AuthenticationCodeModel
    {
        let authCode = try await getAuthCode()
        return try validateAndReturnAuthCode(authCode)
    }

    private func validateAndReturnAuthCode(
        _ authCode: AuthenticationCodeModel?
    ) throws -> AuthenticationCodeModel {
        logValidateCodeStart()
        guard
            let validCode = authCode
        else {
            logInvalidCodeError()
            throw GenericErrors.invalidCode
        }
        logValidCode(code: validCode)
        return validCode
    }

    private func logValidateCodeStart() {
        config.logger.info(
            "Starting validation of authentication code",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "authCodePayload": .string(String(reflecting: config.payload))
            ]
        )
    }

    private func logValidCode(
        code validCode: AuthenticationCodeModel
    ) {
        config.logger.info(
            "Authentication code is valid",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "authCodePayload": .string(String(reflecting: config.payload)),
                "validCode": .string(String(reflecting: validCode)),
            ]
        )
    }

    private func logInvalidCodeError() {
        config.logger.error(
            "Authentication code is invalid",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "authCodePayload": .string(String(reflecting: config.payload))
            ]
        )
    }

    private func getAuthCode() async throws -> AuthenticationCodeModel? {
        try await AuthenticationCodeModel
            .query(on: config.readDb)
            .filter(\.$phoneNumber == config.payload.phoneNumber)
            .filter(\.$code == config.payload.code.lowercased())
            .first()
    }
}

internal struct AuthenticationCodeValidatorConfig: AuthenticationServiceConfig {
    /// DB w/ write access
    public let writeDb: Database
    /// DB w/ readonly access
    public let readDb: Database
    /// Logger
    public let logger: Logger
    /// Payload that will be submitted to auth code validation service
    public let payload: AuthPhoneCodePayloadDTO
}

internal struct AccessTokenResetter {
    private let config: AccessTokenResetterConfig
    private let expiresAt: Date

    /// Initializes
    public init(_ config: AccessTokenResetterConfig) {
        self.config = config
        expiresAt = Date().addingTimeInterval(config.payload.expiresIn)
    }

    /// Removes all tokens after the 5 newest tokens
    public func reset() async throws -> String {
        let signedToken = try await getSignedToken()
        try await OldAccessTokenDeleter(
            .init(
                writeDb: config.writeDb,
                readDb: config.readDb,
                logger: config.logger,
                payload: .init(
                    userId: config.payload.userId,
                    subject: config.payload.subject,
                    totalNewestTokensToSkip: 5
                )
            )
        ).deleteOldTokens()
        try await createAuthToken(fromSignedToken: signedToken)
        return signedToken
    }

    private func createAuthToken(fromSignedToken signedToken: String) async throws {
        try await JwtTokenModel(
            id: UUID(),
            token: signedToken,
            userId: config.payload.userId,
            subject: config.payload.subject,
            deletedAt: expiresAt
        ).create(on: config.writeDb)
    }

    private func getSignedToken() async throws -> String {
        try await config.payload.signer.sign(createTokenToSign())
    }

    private func createTokenToSign() -> JWTTokenPayload {
        JWTTokenPayload(
            subject: config.payload.subject,
            expiration: .init(value: expiresAt),
            userId: config.payload.userId.uuidString,
            tokenId: UUID()
        )
    }
}

internal struct AccessTokenResetterConfig: AuthenticationServiceConfig {
    /// Db w/ write access
    public let writeDb: Database
    /// Db w/ readonly access
    public let readDb: Database
    /// Logger
    public let logger: Logger
    /// Payload submitted to auth token reset service
    public let payload: ResetAccessCodePayload
}

internal struct ResetAccessCodePayload {
    /// The user for which to expire tokens for
    public let userId: UUID
    /// When will the token expire
    public let expiresIn: TimeInterval
    /// Subject
    public let subject: JWTTokenSubject
    /// JWT Signer Service
    public let signer: Request.JWT
}

internal struct OldAccessTokenDeleter {
    /// Old Access token deleter config
    public let config: OldAccessTokenDeleterConfig

    /// Initializes token deletion service
    public init(_ config: OldAccessTokenDeleterConfig) {
        self.config = config
    }

    /// Deletes old access tokens
    public func deleteOldTokens() async throws {
        logDeleteOldTokensStart()
        try await deleteTokens(getTokensToDelete())
    }

    private func deleteTokens(_ tokens: [JwtTokenModel]) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for token in tokens {
                group.addTask {
                    try await deleteToken(token)
                }
            }

            try await group.waitForAll()
        }
    }

    private func deleteToken(_ token: JwtTokenModel) async throws {
        try await token.delete(on: config.writeDb)
        try logDeleteTokenSuccess(id: token.requireID())
    }

    private func logDeleteTokenSuccess(id: UUID) {
        config.logger.info(
            "Deleted token",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "tokenId": .string(id.uuidString)
            ]
        )
    }

    private func getTokensToDelete() async throws -> [JwtTokenModel] {
        try await getQueryForTokensToDelete().all()
    }

    private func getQueryForTokensToDelete() -> QueryBuilder<JwtTokenModel> {
        var query = getQueryForAllTokensInDescendingOrder()
        if let totalNewestTokensToSkip = config.payload.totalNewestTokensToSkip {
            query = skipSomeNewestTokens(amount: totalNewestTokensToSkip, fromQuery: query)
        }
        return query
    }

    private func skipSomeNewestTokens(
        amount: Int,
        fromQuery query: QueryBuilder<JwtTokenModel>
    ) -> QueryBuilder<JwtTokenModel> {
        query.range(amount...)
    }

    private func getQueryForAllTokensInDescendingOrder() -> QueryBuilder<JwtTokenModel> {
        JwtTokenModel.query(on: config.writeDb)
            .filter(\.$userId == config.payload.userId)
            .filter(\.$subject == config.payload.subject)
            .sort(\.$createdAt, .descending)
    }

    private func logDeleteOldTokensStart() {
        config.logger.info(
            "Deleting old tokens",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "userId": .string(config.payload.userId.uuidString),
                "subject": .string(String(reflecting: config.payload.subject)),
                "skip": .string(String(reflecting: config.payload.totalNewestTokensToSkip)),
            ]
        )
    }
}

internal struct OldAccessTokenDeleterConfig: AuthenticationServiceConfig {
    /// Db w/ write access
    public let writeDb: Database
    /// Db w/ readonly access
    public let readDb: Database
    /// Logger
    public let logger: Logger
    /// Payload to submit to old access deletion service
    public let payload: DeleteOldAccessTokensPayload
}

internal struct DeleteOldAccessTokensPayload {
    /// User id for which to delete tokens for
    public let userId: UUID
    /// Subject
    public let subject: JWTTokenSubject
    /// ASC on date how many tokens to skip
    public let totalNewestTokensToSkip: Int?

    /// init
    public init(
        userId: UUID,
        subject: JWTTokenSubject,
        totalNewestTokensToSkip: Int? = nil
    ) {
        self.userId = userId
        self.subject = subject
        self.totalNewestTokensToSkip = totalNewestTokensToSkip
    }
}

internal struct AuthenticationTokensPayloadCreator {
    private let config: AuthenticationTokensPayloadCreatorConfig
    private let eventService = EventNotificationService()

    /// Initializes token
    public init(_ config: AuthenticationTokensPayloadCreatorConfig) {
        self.config = config
    }

    /// Creates authentication token
    public func create(
    ) async throws -> AuthenticationTokensPayloadDTO {
        logCreateStart()
        let tokensPayload = try await createTokensPayload()
        try sendTelemetryDataOnCreateSuccess(payload: tokensPayload)

        return tokensPayload
    }

    private func sendTelemetryDataOnCreateSuccess(payload tokensPayload: AuthenticationTokensPayloadDTO) throws {
        logCreateSuccess(payload: tokensPayload)
        try alertCreateSuccess(payload: tokensPayload)
    }

    private func alertCreateSuccess(payload tokensPayload: AuthenticationTokensPayloadDTO) throws {
        try eventService.sendAppEvent(
            input: config.payload.userId.uuidString,
            event: """
            generated tokens:
                `access: \(tokensPayload.accessToken.count)`
                `refresh: \(tokensPayload.refreshToken.count)`
            """,
            logger: config.logger
        )
    }

    private func logCreateSuccess(payload tokensPayload: AuthenticationTokensPayloadDTO) {
        config.logger.info(
            "Successfully created authentication tokens payload",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "userId": .string(config.payload.userId.uuidString),
                "accessTokenLength": .string("\(tokensPayload.accessToken.count)"),
                "refreshTokenLength": .string("\(tokensPayload.refreshToken.count)"),
            ]
        )
    }

    private func createTokensPayload() async throws -> AuthenticationTokensPayloadDTO {
        try await .init(
            accessToken: resetAccessToken(subject: .access),
            refreshToken: resetAccessToken(subject: .refresh)
        )
    }

    private func resetAccessToken(subject: JWTTokenSubject) async throws -> String {
        try await AccessTokenResetter(.init(
            writeDb: config.writeDb,
            readDb: config.readDb,
            logger: config.logger,
            payload: .init(
                userId: config.payload.userId,
                expiresIn: getExpiresInFromSubject(subject),
                subject: subject,
                signer: config.payload.signer
            )
        )).reset()
    }

    private func getExpiresInFromSubject(_ subject: JWTTokenSubject) -> TimeInterval {
        switch subject {
        case .refresh:
            31_536_000
        default:
            86_400
        }
    }

    private func logCreateStart() {
        config.logger.info(
            "Creating authentication tokens payload",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "userId": .string(config.payload.userId.uuidString),
            ]
        )
    }
}

internal struct AuthenticationTokensPayloadCreatorConfig: AuthenticationServiceConfig {
    /// Db w/ write access
    public let writeDb: Database
    /// Db w/ readonly access
    public let readDb: Database
    /// Logger
    public let logger: Logger
    /// Create auth token payload
    public let payload: CreateAuthenticationTokensPayload
}

internal struct CreateAuthenticationTokensPayload {
    /// User id for which to create a token for
    public let userId: UUID
    /// JWT signer
    public let signer: Request.JWT
}

internal struct AuthCodeSender {
    private let config: AuthCodeSenderConfig

    /// Initializes auth code sender
    public init(_ config: AuthCodeSenderConfig) {
        self.config = config
    }

    /// Sends authentication token
    public func send() async throws -> AuthenticationCodeResponseDTO {
        try await deliverCode()
        try await createAuthCodeModel()
        sendTelemetryDataOnSendSuccess()
        return sendSuccess()
    }

    private func sendSuccess() -> AuthenticationCodeResponseDTO {
        .init(success: true, timeout: 60)
    }

    private func sendTelemetryDataOnSendSuccess() {
        config.logger.info(
            "Sent verification code to user",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "phoneNumber": .string(config.payload.phoneNumber),
                "code": .string(config.payload.code),
                "codeId": .string(config.payload.codeModelId.uuidString),
            ]
        )

        BackendMetric.totalSuccessfulVerificationCodesSent.increment()
    }

    private func createAuthCodeModel() async throws {
        try await AuthenticationCodeModel(
            id: config.payload.codeModelId,
            code: config.payload.code,
            phoneNumber: config.payload.phoneNumber,
            deletedAt: getCodeDeletionTime()
        ).save(on: config.writeDb)
    }

    private func deliverCode() async throws {
        do {
            try await config.codeDelivery.send(
                code: config.payload.code,
                toPhoneNumber: config.payload.phoneNumber
            )
        } catch {
            config.logger.error(
                "Error occurred while delivering authentication code",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string(error.localizedDescription),
                ]
            )

            throw error
        }
    }

    private func getCodeDeletionTime() -> Date {
        Date().addingTimeInterval(15 * 60)
    }
}

internal struct AuthCodeSenderConfig: AuthenticationServiceConfig {
    /// Db w/ write access
    public let writeDb: Database
    /// Db w/ readonly access
    public let readDb: Database
    /// Logger
    public let logger: Logger
    /// Delivery service used to send the code to the user
    public let codeDelivery: any AuthCodeDeliveryService
    /// Payload to submit
    public let payload: SendAuthCodePayload
}

internal struct SendAuthCodePayload {
    /// Code to send
    public let code: String
    /// Phone number to send code to
    public let phoneNumber: String
    /// Code ID
    public let codeModelId: UUID
}
