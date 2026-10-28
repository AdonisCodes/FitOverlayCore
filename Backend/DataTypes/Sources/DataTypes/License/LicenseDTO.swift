// LicenseDTO.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

/// The commercial plan a licence was purchased under.
/// FitOverlay is sold as a one-time lifetime licence across platforms, with
/// subscriptions supported as an alternative billing model.
public enum LicensePlan: String, Codable, Sendable, CaseIterable {
    /// One-time payment, valid forever on all platforms
    case lifetime
    /// Recurring subscription (monthly/annual handled by the payment provider)
    case subscription
}

/// The lifecycle state of a licence.
public enum LicenseStatus: String, Codable, Sendable, CaseIterable {
    /// Licence is valid and can be used/activated
    case active
    /// Subscription lapsed (payment failed or cancelled); kept for reactivation
    case expired
    /// Licence was refunded or revoked by support
    case revoked
}

/// The platform a device activation belongs to.
/// Kept as a plain string-backed enum so new platforms (Windows, web) can be added
/// without a database migration.
public enum LicenseDevicePlatform: String, Codable, Sendable, CaseIterable {
    case macOS
    case iOS
    case windows
    case web
    case other
}

/// A data transfer object representing a licence.
public struct LicenseDTO: Content {
    /// The unique identifier for the licence record
    public var id: UUID?

    /// The human-readable licence key (e.g. `FITO-XXXX-XXXX-XXXX-XXXX`)
    public var key: String

    /// The user this licence belongs to, when the purchase has been linked to an account
    public var userId: UUID?

    /// The plan the licence was purchased under
    public var plan: LicensePlan

    /// The lifecycle status of the licence
    public var status: LicenseStatus

    /// The maximum number of concurrently activated devices
    public var maxActivations: Int

    /// Timestamp when the licence was created
    public var createdAt: Date?

    /// Timestamp when the licence was last updated
    public var updatedAt: Date?

    /// For subscriptions: when the current billing period ends. Nil for lifetime licences.
    public var expiresAt: Date?

    /// Initializes a new licence DTO.
    public init(
        id: UUID? = nil,
        key: String,
        userId: UUID? = nil,
        plan: LicensePlan,
        status: LicenseStatus,
        maxActivations: Int,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        expiresAt: Date? = nil
    ) {
        self.id = id
        self.key = key
        self.userId = userId
        self.plan = plan
        self.status = status
        self.maxActivations = maxActivations
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.expiresAt = expiresAt
    }
}
