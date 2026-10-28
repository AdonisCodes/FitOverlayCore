// DeviceActivationModel.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

/// Model representing a single device activation of a licence.
public final class DeviceActivationModel: Model, @unchecked Sendable {
    public static let schema = "Device-Activation"

    /// Unique identifier for the activation.
    @ID(key: .id)
    public var id: UUID?

    /// The licence this activation belongs to.
    @Parent(key: "license_id")
    public var license: LicenseModel

    /// A stable, client-generated identifier for the device.
    @Field(key: "device_identifier")
    public var deviceIdentifier: String

    /// A human-friendly device name (e.g. "Simon's MacBook Pro").
    @Field(key: "device_name")
    public var deviceName: String

    /// The platform the device runs on.
    @Enum(key: "platform")
    public var platform: LicenseDevicePlatform

    /// Timestamp when the device was activated.
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?

    /// Timestamp when the activation was last refreshed.
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?

    /// Timestamp when the activation was deleted (deactivated).
    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?

    /// Initializes a new instance of `DeviceActivationModel`.
    public init() {}

    /// Initializes a new instance of `DeviceActivationModel` with the provided parameters.
    public init(
        id: UUID? = nil,
        licenseID: UUID,
        deviceIdentifier: String,
        deviceName: String,
        platform: LicenseDevicePlatform,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.deviceIdentifier = deviceIdentifier
        self.deviceName = deviceName
        self.platform = platform
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        $license.id = licenseID
    }

    /// Converts the model to a `DeviceActivationDTO`.
    public func toDTO() -> DeviceActivationDTO {
        .init(
            id: id,
            licenseId: $license.id,
            deviceIdentifier: deviceIdentifier,
            deviceName: deviceName,
            platform: platform,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    deinit {
        return
    }
}
