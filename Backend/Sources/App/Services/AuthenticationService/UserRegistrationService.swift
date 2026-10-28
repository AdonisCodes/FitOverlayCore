// UserRegistrationService.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import AutomaUtilities
import DataTypes
import Fluent
import JWT
import Temporal
import Vapor

internal struct UserRegistrationService: AuthenticationService {
    private var config: UserRegistrationConfig
    internal let helper: AuthenticationServiceHelper
    internal let messageService = MessageService()
    private let identifier: UserIdentifier
    private var user: UserModel

    /// Initializes User Registration Service
    public init(_ config: UserRegistrationConfig) {
        self.config = config
        helper = .init(.init(writeDb: config.writeDb, readDb: config.readDb, logger: config.logger))
        identifier = Self.generateNewUserIdentifier()
        user = Self.createUserModel(identifier: identifier, config: config)
    }

    /// Registers User & Creates Profile Photo
    public mutating func register() async throws -> AuthenticationTokensPayloadDTO {
        try await helper.validateAndDeleteCode(config.payload.authCodePayload)

        try await generateUserProfilePicture(&user)
        try sendTelemetryDataOnRegistrationSuccess()

        return try await helper.createAuthenticationTokensPayload(.init(
            userId: identifier.id,
            signer: config.payload.signer
        ))
    }

    private func sendTelemetryDataOnRegistrationSuccess() throws {
        BackendMetric.totalUsersCreated.increment()

        config.logger.info(
            "Successfully Registered User",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "userIdentifier": .string(String(reflecting: identifier))
            ]
        )

        try messageService
            .sendDiscordWebhookAppEvent(
                input: "\(config.payload.authCodePayload.phoneNumber) - \(identifier.id)",
                event: "created an account with \(identifier.name)",
                logger: config.logger
            )
    }

    private static func createUserModel(identifier: UserIdentifier, config: UserRegistrationConfig) -> UserModel {
        UserModel(
            id: identifier.id,
            username: identifier.name,
            phoneNumber: config.payload.authCodePayload.phoneNumber,
            accepted: false
        )
    }

    private func generateUserProfilePicture(_ user: inout UserModel) async throws {
        let userDTO = try user.toDTO(logger: config.logger)
        let profilePictureKey = try ProfilePictureService(logger: config.logger).generateImageKey(for: userDTO)

        let temporalClient = config.temporalClient
        _ = try await temporalClient.startWorkflow(
            type: CreateProfilePictureWorkflow.self,
            options: .init(
                id: "create-user-profile-pic-\(userDTO.id?.uuidString ?? userDTO.username)-\(Date())",
                taskQueue: "default-queue"
            ),
            input: .init(payload: userDTO)
        )

        user.profilePictureKey = profilePictureKey

        try await user.save(on: config.writeDb)
    }

    private static func generateNewUserIdentifier() -> UserIdentifier {
        .init(
            name: RandomService.randomUsername(),
            id: UUID()
        )
    }

    internal struct UserIdentifier: Content {
        /// UserName
        public let name: String
        /// UserId
        public let id: UUID
    }
}

internal struct UserRegistrationConfig: AuthenticationServiceConfig {
    /// Db w/ write access
    public let writeDb: Database
    /// Db w/ readonly access
    public let readDb: Database
    /// Logger
    public let logger: Logger
    // Temporal client to execute workflows
    public let temporalClient: TemporalClient
    /// Payload to register user
    public let payload: UserRegistrationPayload
}

internal struct UserRegistrationPayload {
    /// Auth code payload
    public let authCodePayload: AuthPhoneCodePayloadDTO
    /// Token Signer
    public let signer: Request.JWT
}
