// DeviceActivationDTO.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

/// A data transfer object representing a single device activation of a licence.
public struct DeviceActivationDTO: Content {
    /// The unique identifier for the activation record
    public var id: UUID?

    /// The licence this activation belongs to
    public var licenseId: UUID

    /// A stable, client-generated identifier for the device
    public var deviceIdentifier: String

    /// A human-friendly device name (e.g. "Simon's MacBook Pro")
    public var deviceName: String

    /// The platform the device runs on
    public var platform: LicenseDevicePlatform

    /// Timestamp when the device was activated
    public var createdAt: Date?

    /// Timestamp when the activation was last refreshed
    public var updatedAt: Date?

    /// Initializes a new device activation DTO.
    public init(
        id: UUID? = nil,
        licenseId: UUID,
        deviceIdentifier: String,
        deviceName: String,
        platform: LicenseDevicePlatform,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.licenseId = licenseId
        self.deviceIdentifier = deviceIdentifier
        self.deviceName = deviceName
        self.platform = platform
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Payload sent by a client to activate (or refresh) a device against a licence key.
public struct LicenseActivationRequestDTO: Content {
    /// The licence key entered by the user
    public let key: String

    /// A stable, client-generated identifier for the device
    public let deviceIdentifier: String

    /// A human-friendly device name
    public let deviceName: String

    /// The platform the device runs on
    public let platform: LicenseDevicePlatform

    /// Initializes a new activation request payload.
    public init(key: String, deviceIdentifier: String, deviceName: String, platform: LicenseDevicePlatform) {
        self.key = key
        self.deviceIdentifier = deviceIdentifier
        self.deviceName = deviceName
        self.platform = platform
    }
}

/// Payload sent by a client to deactivate a device, freeing up an activation slot.
public struct LicenseDeactivationRequestDTO: Content {
    /// The licence key the device was activated against
    public let key: String

    /// The stable device identifier to deactivate
    public let deviceIdentifier: String

    /// Initializes a new deactivation request payload.
    public init(key: String, deviceIdentifier: String) {
        self.key = key
        self.deviceIdentifier = deviceIdentifier
    }
}

/// Response returned to clients describing the state of a licence after an operation.
public struct LicenseStatusResponseDTO: Content {
    /// The licence the operation was performed on
    public let license: LicenseDTO

    /// All currently active device activations for the licence
    public let activations: [DeviceActivationDTO]

    /// Whether the requesting device currently holds an activation slot
    public let isDeviceActivated: Bool

    /// Initializes a new licence status response.
    public init(license: LicenseDTO, activations: [DeviceActivationDTO], isDeviceActivated: Bool) {
        self.license = license
        self.activations = activations
        self.isDeviceActivated = isDeviceActivated
    }
}
