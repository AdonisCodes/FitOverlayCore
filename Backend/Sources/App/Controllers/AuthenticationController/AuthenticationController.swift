// AuthenticationController.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

/// Controller for handling authentication-related routes.
internal struct AuthenticationController: RouteCollection {
    /// Registers routes for authentication operations.
    /// - Parameter routes: The routes builder to register routes on.
    public func boot(routes: RoutesBuilder) throws {
        let authenticationRoute = routes.grouped("Authentication")

        authenticationRoute.post("register", use: register)
        authenticationRoute.post("register-code", use: registerCode)

        authenticationRoute.post("login-code", use: loginCode)

        authenticationRoute.get("refresh-token", use: refreshToken)
        authenticationRoute.post("login", use: login)

        let authenticatedRouteGroup = authenticationRoute.grouped(
            RequestIsAuthenticatedMiddleware()
        )

        authenticatedRouteGroup.post("logout", use: logout)
    }

    /// Sends a registration code to the user's phone number.
    /// - Parameter req: The request containing the phone number.
    /// - Returns: A DTO containing the authentication code response.
    /// - Throws: An error if the user already exists or sending the code fails.
    @Sendable
    public func registerCode(req: Request) async throws -> AuthenticationCodeResponseDTO {
        let dto = try req.content.decode(PhoneNumberPayloadDTO.self)

        let authService = RootAuthenticationService(.init(
            writeDb: req.dbWrite,
            readDb: req.dbReadOnly,
            logger: req.logger
        ))

        if try await authService.doesUserExist(phoneNumber: dto.phoneNumber) {
            throw GenericErrors.userAlreadyExists
        }

        return try await authService.sendAuthCode(
            phoneNumber: dto.phoneNumber,
            codeDelivery: req.authCodeDelivery
        )
    }

    /// Registers a new user with the provided phone number and code.
    /// - Parameter req: The request containing the phone number and code.
    /// - Returns: A DTO containing the authentication tokens.
    /// - Throws: An error if the user already exists or registration fails.
    @Sendable
    public func register(req: Request) async throws -> AuthenticationTokensPayloadDTO {
        let dto = try req.content.decode(AuthPhoneCodePayloadDTO.self)
        let authService = RootAuthenticationService(.init(
            writeDb: req.dbWrite,
            readDb: req.dbReadOnly,
            logger: req.logger
        ))

        if try await authService.doesUserExist(phoneNumber: dto.phoneNumber) {
            throw GenericErrors.userAlreadyExists
        }

        return try await authService.register(
            .init(authCodePayload: dto, signer: req.jwt),
            codeDelivery: req.authCodeDelivery
        )
    }

    /// Sends a login code to the user's phone number.
    /// - Parameter req: The request containing the phone number.
    /// - Returns: A DTO containing the authentication code response.
    /// - Throws: An error if the user is not found or sending the code fails.
    @Sendable
    public func loginCode(req: Request) async throws -> AuthenticationCodeResponseDTO {
        let dto = try req.content.decode(PhoneNumberPayloadDTO.self)

        let authService = RootAuthenticationService(.init(
            writeDb: req.dbWrite,
            readDb: req.dbReadOnly,
            logger: req.logger
        ))

        if try await !(authService.doesUserExist(phoneNumber: dto.phoneNumber)) {
            throw GenericErrors.userNotFound
        }

        return try await authService.sendAuthCode(
            phoneNumber: dto.phoneNumber,
            codeDelivery: req.authCodeDelivery
        )
    }

    /// Logs in a user with the provided phone number and code.
    /// - Parameter req: The request containing the phone number and code.
    /// - Returns: A DTO containing the authentication tokens.
    /// - Throws: An error if login fails.
    @Sendable
    public func login(req: Request) async throws -> AuthenticationTokensPayloadDTO {
        let dto = try req.content.decode(AuthPhoneCodePayloadDTO.self)
        let authService = RootAuthenticationService(.init(
            writeDb: req.dbWrite,
            readDb: req.dbReadOnly,
            logger: req.logger
        ))

        return try await authService.login(.init(authCodePayload: dto, signer: req.jwt))
    }

    /// Refreshes the user's access token.
    /// - Parameter req: The request containing the refresh token.
    /// - Returns: A DTO containing the new access token.
    /// - Throws: An error if the token is invalid or refreshing fails.
    @Sendable
    public func refreshToken(req: Request) async throws -> AccessTokenPayloadDTO {
        let tokenString = try req.query.get(String?.self, at: "xxrt")

        guard let tokenString else {
            throw GenericErrors.invalidToken
        }

        let token = try await req.jwt.verify(
            tokenString,
            as: JWTTokenPayload.self
        )

        if token.subject != .refresh {
            throw GenericErrors.invalidToken
        }

        let authService = RootAuthenticationService(.init(
            writeDb: req.dbWrite,
            readDb: req.dbReadOnly,
            logger: req.logger
        ))

        do {
            let userId = try UUID.unwrapFromString(token.userId) {
                throw GenericErrors.invalidUserId
            }

            let refreshedAccessToken = try await authService.refreshToken(
                userId: userId,
                signer: req.jwt
            )
            BackendMetric.totalSuccessfulTokensRefreshed.increment()
            return .init(accessToken: refreshedAccessToken)
        } catch {
            BackendMetric.totalFailedTokensRefreshed.increment()
            throw error
        }
    }

    /// Logs out the user.
    /// - Parameter req: The request containing the user's token.
    /// - Returns: HTTP status indicating the result of the operation.
    /// - Throws: An error if logout fails.
    @Sendable
    public func logout(req: Request) async throws -> HTTPStatus {
        let token = try await req.jwt.verify(as: JWTTokenPayload.self)

        let userId = UUID(uuidString: token.userId)

        do {
            if let userId {
                let authService = RootAuthenticationService(.init(
                    writeDb: req.dbWrite,
                    readDb: req.dbReadOnly,
                    logger: req.logger
                ))

                try await authService.logout(userId: userId)
            } else {
                throw GenericErrors.invalidUserId
            }
        } catch {
            req.logger.error(
                "Failed to log user out",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string("\(error.localizedDescription)"),
                ]
            )
            BackendMetric.totalFailedLogoutAttempted.increment()
            throw error
        }

        BackendMetric.totalLogoutAttempted.increment()
        return .ok
    }
}

internal extension Request {
    /// The verification code delivery service for this request.
    /// Currently the logging stub; swap for a real SMS/email provider in production.
    var authCodeDelivery: any AuthCodeDeliveryService {
        LoggingAuthCodeDeliveryService(logger: logger)
    }
}
