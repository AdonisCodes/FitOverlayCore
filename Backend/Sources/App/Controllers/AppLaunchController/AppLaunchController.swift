// AppLaunchController.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

/// Controller for handling app launch-related routes.
internal struct AppLaunchController: RouteCollection {
    /// Registers routes for app launch operations.
    /// - Parameter routes: The routes builder to register routes on.
    public func boot(routes: RoutesBuilder) throws {
        let appLaunchRoute = routes.grouped("App-Launch")

        let authenticatedRouteGroup = appLaunchRoute.grouped(
            RequestIsAuthenticatedMiddleware()
        )

        authenticatedRouteGroup.get("is-user-accepted", use: isUserAccepted)
        appLaunchRoute.get("get-client-config", use: getClientConfig)
    }

    /// Checks if the user is accepted.
    /// - Parameter req: The request containing user information.
    /// - Returns: A DTO indicating if the user is accepted.
    /// - Throws: An error if the user ID is invalid or not found.
    @Sendable
    public func isUserAccepted(req: Request) async throws -> UserIsAcceptedDTO {
        let token = try await req.jwt.verify(as: JWTTokenPayload.self)
        let userId = UUID(uuidString: token.userId)

        if let userId {
            let isAccepted = try await UserModel.find(userId, on: req.dbReadOnly)?.accepted ?? false
            return UserIsAcceptedDTO(accepted: isAccepted)
        } else {
            throw GenericErrors.invalidUserId
        }
    }

    /// Retrieves the client configuration.
    /// - Parameter req: The request object.
    /// - Returns: A DTO containing the client configuration.
    @Sendable
    public func getClientConfig(req _: Request) throws -> AppLaunchClientConfigDTO {
        .init()
    }
}
