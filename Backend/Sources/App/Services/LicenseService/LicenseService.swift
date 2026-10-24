// LicenseService.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import AutomaUtilities
import DataTypes
import Fluent
import Vapor

/// Service encapsulating licence lifecycle logic: key generation, device activation
/// across platforms, and purchase fulfilment.
internal struct LicenseService {
    private let config: LicenseServiceConfig
    private let messageService = MessageService()

    /// Default number of devices a licence can be active on at the same time.
    public static let defaultMaxActivations = 5

    /// Initializes the licence service
    public init(_ config: LicenseServiceConfig) {
        self.config = config
    }

    // MARK: - Key generation

    /// Generates a new human-readable licence key of the form `FITO-XXXX-XXXX-XXXX-XXXX`.
    /// Ambiguous characters (0/O, 1/I) are excluded to make manual entry easier.
    public static func generateKey() -> String {
        let alphabet = Array("23456789ABCDEFGHJKLMNPQRSTUVWXYZ")
        let groups = (0 ..< 4).map { _ in
            String((0 ..< 4).compactMap { _ in alphabet.randomElement() })
        }
        return (["FITO"] + groups).joined(separator: "-")
    }

    // MARK: - Fulfilment

    /// Creates a licence for a completed purchase.
    /// Called by the purchase webhook handlers once the provider event is verified.
    /// - Parameter event: The normalized purchase event.
    /// - Returns: The newly created licence.
    public func fulfillPurchase(_ event: PurchaseWebhookEventDTO) async throws -> LicenseModel {
        let license = LicenseModel(
            key: Self.generateKey(),
            plan: event.plan,
            status: .active,
            maxActivations: Self.defaultMaxActivations,
            expiresAt: nil
        )
        try await license.create(on: config.writeDb)

        BackendMetric.totalPurchaseWebhooksReceived.increment()
        try messageService.sendDiscordWebhookAppEvent(
            input: event.customerEmail ?? "unknown-customer",
            event: "purchased a \(event.plan.rawValue) licence via \(event.provider.rawValue)",
            logger: config.logger
        )

        // TODO: Deliver the licence key to `event.customerEmail` once an email provider is wired up.
        return license
    }

    // MARK: - Activation

    /// Activates (or refreshes) a device against a licence key.
    /// - Parameter payload: The activation request from the client.
    /// - Returns: The licence status after activation.
    /// - Throws: `GenericErrors.invalidLicenseKey`, `.licenseNotActive`,
    ///           or `.licenseActivationLimitReached`.
    public func activateDevice(_ payload: LicenseActivationRequestDTO) async throws -> LicenseStatusResponseDTO {
        let license = try await findActiveLicense(key: payload.key)
        let licenseId = try license.requireID()

        let activations = try await currentActivations(licenseId: licenseId)

        if let existing = activations.first(where: { $0.deviceIdentifier == payload.deviceIdentifier }) {
            // Refresh the existing activation (device name may have changed).
            existing.deviceName = payload.deviceName
            existing.platform = payload.platform
            try await existing.save(on: config.writeDb)
            return try await statusResponse(license: license, requestingDevice: payload.deviceIdentifier)
        }

        guard activations.count < license.maxActivations else {
            BackendMetric.totalFailedLicenseActivations.increment()
            throw GenericErrors.licenseActivationLimitReached
        }

        try await DeviceActivationModel(
            licenseID: licenseId,
            deviceIdentifier: payload.deviceIdentifier,
            deviceName: payload.deviceName,
            platform: payload.platform
        ).create(on: config.writeDb)

        BackendMetric.totalLicenseActivations.increment()
        try messageService.sendDiscordWebhookAppEvent(
            input: payload.deviceIdentifier,
            event: "activated licence \(license.key) on \(payload.platform.rawValue)",
            logger: config.logger
        )

        return try await statusResponse(license: license, requestingDevice: payload.deviceIdentifier)
    }

    /// Deactivates a device, freeing an activation slot.
    /// - Parameter payload: The deactivation request from the client.
    /// - Returns: The licence status after deactivation.
    /// - Throws: `GenericErrors.invalidLicenseKey` when the key is unknown.
    public func deactivateDevice(_ payload: LicenseDeactivationRequestDTO) async throws -> LicenseStatusResponseDTO {
        let license = try await findLicense(key: payload.key)
        let licenseId = try license.requireID()

        if let activation = try await DeviceActivationModel
            .query(on: config.writeDb)
            .filter(\.$license.$id == licenseId)
            .filter(\.$deviceIdentifier == payload.deviceIdentifier)
            .first()
        {
            try await activation.delete(on: config.writeDb)
        }

        return try await statusResponse(license: license, requestingDevice: payload.deviceIdentifier)
    }

    /// Returns the status of a licence and its activations.
    /// - Parameters:
    ///   - key: The licence key to look up.
    ///   - deviceIdentifier: Optional requesting device, used to compute `isDeviceActivated`.
    /// - Throws: `GenericErrors.invalidLicenseKey` when the key is unknown.
    public func status(key: String, deviceIdentifier: String?) async throws -> LicenseStatusResponseDTO {
        let license = try await findLicense(key: key)
        return try await statusResponse(license: license, requestingDevice: deviceIdentifier)
    }

    // MARK: - Private helpers

    private func findLicense(key: String) async throws -> LicenseModel {
        guard let license = try await LicenseModel
            .query(on: config.readDb)
            .filter(\.$key == key)
            .first()
        else {
            throw GenericErrors.invalidLicenseKey
        }
        return license
    }

    private func findActiveLicense(key: String) async throws -> LicenseModel {
        let license = try await findLicense(key: key)

        guard license.status == .active else {
            throw GenericErrors.licenseNotActive
        }

        if let expiresAt = license.expiresAt, expiresAt < Date() {
            throw GenericErrors.licenseNotActive
        }

        return license
    }

    private func currentActivations(licenseId: UUID) async throws -> [DeviceActivationModel] {
        try await DeviceActivationModel
            .query(on: config.readDb)
            .filter(\.$license.$id == licenseId)
            .all()
    }

    private func statusResponse(
        license: LicenseModel,
        requestingDevice: String?
    ) async throws -> LicenseStatusResponseDTO {
        let activations = try await currentActivations(licenseId: license.requireID())
        return .init(
            license: license.toDTO(),
            activations: activations.map { $0.toDTO() },
            isDeviceActivated: requestingDevice.map { device in
                activations.contains { $0.deviceIdentifier == device }
            } ?? false
        )
    }
}

internal struct LicenseServiceConfig {
    /// Db w/ write access
    public let writeDb: Database
    /// Db w/ readonly access
    public let readDb: Database
    /// Logger
    public let logger: Logger
}
