// LicenseController.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

/// Controller for licence, device activation, and purchase webhook routes.
///
/// Routes:
/// - `POST /License/activate`            — activate (or refresh) a device for a licence key
/// - `POST /License/deactivate`          — free an activation slot
/// - `GET  /License/status`              — look up a licence and its activations
/// - `POST /License/webhooks/stripe`     — Stripe purchase webhook (stub)
/// - `POST /License/webhooks/app-store`  — App Store server notification webhook (stub)
internal struct LicenseController: RouteCollection {
    /// Registers routes for licence operations.
    /// - Parameter routes: The routes builder to register routes on.
    public func boot(routes: RoutesBuilder) throws {
        let licenseRoute = routes.grouped("License")

        licenseRoute.post("activate", use: activate)
        licenseRoute.post("deactivate", use: deactivate)
        licenseRoute.get("status", use: status)

        let webhooks = licenseRoute.grouped("webhooks")
        webhooks.post("stripe", use: stripeWebhook)
        webhooks.post("app-store", use: appStoreWebhook)
    }

    /// Activates a device against a licence key.
    /// - Parameter req: The request containing a `LicenseActivationRequestDTO`.
    /// - Returns: The licence status after activation.
    /// - Throws: Licence errors when the key is unknown, inactive, or at its activation limit.
    @Sendable
    public func activate(req: Request) async throws -> LicenseStatusResponseDTO {
        let dto = try req.content.decode(LicenseActivationRequestDTO.self)
        return try await licenseService(req).activateDevice(dto)
    }

    /// Deactivates a device, freeing up an activation slot.
    /// - Parameter req: The request containing a `LicenseDeactivationRequestDTO`.
    /// - Returns: The licence status after deactivation.
    /// - Throws: `GenericErrors.invalidLicenseKey` when the key is unknown.
    @Sendable
    public func deactivate(req: Request) async throws -> LicenseStatusResponseDTO {
        let dto = try req.content.decode(LicenseDeactivationRequestDTO.self)
        return try await licenseService(req).deactivateDevice(dto)
    }

    /// Returns the status of a licence.
    /// Query parameters: `key` (required), `deviceIdentifier` (optional).
    /// - Parameter req: The request with licence key query parameters.
    /// - Returns: The licence status.
    /// - Throws: `GenericErrors.invalidLicenseKey` when the key is unknown.
    @Sendable
    public func status(req: Request) async throws -> LicenseStatusResponseDTO {
        guard let key = try req.query.get(String?.self, at: "key") else {
            throw GenericErrors.invalidLicenseKey
        }
        let deviceIdentifier = try req.query.get(String?.self, at: "deviceIdentifier")

        return try await licenseService(req).status(key: key, deviceIdentifier: deviceIdentifier)
    }

    /// Stripe purchase webhook (stub).
    ///
    /// TODO: Verify the `Stripe-Signature` header against `STRIPE_WEBHOOK_SECRET` and decode
    /// the real Stripe event payload. For now this accepts the normalized
    /// `PurchaseWebhookEventDTO` shape so the fulfilment flow can be exercised end-to-end.
    /// - Parameter req: The webhook request.
    /// - Returns: An acknowledgement including the generated licence key.
    @Sendable
    public func stripeWebhook(req: Request) async throws -> PurchaseWebhookResponseDTO {
        var dto = try req.content.decode(PurchaseWebhookEventDTO.self)
        dto = .init(
            provider: .stripe,
            eventType: dto.eventType,
            plan: dto.plan,
            customerEmail: dto.customerEmail,
            providerTransactionId: dto.providerTransactionId
        )

        let license = try await licenseService(req).fulfillPurchase(dto)
        return .init(received: true, licenseKey: license.key)
    }

    /// App Store server notification webhook (stub).
    ///
    /// TODO: Verify and decode the signed JWS payload of App Store Server Notifications V2.
    /// For now this accepts the normalized `PurchaseWebhookEventDTO` shape.
    /// - Parameter req: The webhook request.
    /// - Returns: An acknowledgement including the generated licence key.
    @Sendable
    public func appStoreWebhook(req: Request) async throws -> PurchaseWebhookResponseDTO {
        var dto = try req.content.decode(PurchaseWebhookEventDTO.self)
        dto = .init(
            provider: .appStore,
            eventType: dto.eventType,
            plan: dto.plan,
            customerEmail: dto.customerEmail,
            providerTransactionId: dto.providerTransactionId
        )

        let license = try await licenseService(req).fulfillPurchase(dto)
        return .init(received: true, licenseKey: license.key)
    }

    private func licenseService(_ req: Request) -> LicenseService {
        LicenseService(.init(
            writeDb: req.dbWrite,
            readDb: req.dbReadOnly,
            logger: req.logger
        ))
    }
}
