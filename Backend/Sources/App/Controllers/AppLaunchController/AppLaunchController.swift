// AppLaunchController.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import DataTypes
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

    /// Reports that the signed-in account can use the app.
    ///
    /// Older clients call this before leaving the pending-review screen. Accounts are no longer
    /// reviewed, so every authenticated caller is accepted.
    /// - Parameter req: The authenticated request.
    /// - Returns: A DTO with `accepted` set to true.
    @Sendable
    public func isUserAccepted(req _: Request) async throws -> UserIsAcceptedDTO {
        UserIsAcceptedDTO(accepted: true)
    }

    /// Retrieves the client configuration.
    /// - Parameter req: The request object.
    /// - Returns: A DTO containing the client configuration.
    @Sendable
    public func getClientConfig(req _: Request) throws -> AppLaunchClientConfigDTO {
        .init()
    }
}
