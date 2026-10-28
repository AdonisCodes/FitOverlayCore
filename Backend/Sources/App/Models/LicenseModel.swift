// LicenseModel.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

/// Model representing a FitOverlay licence.
/// A licence is created when a purchase completes (webhook) and can be activated on a
/// limited number of devices across platforms.
public final class LicenseModel: Model, @unchecked Sendable {
    public static let schema = "License"

    /// Unique identifier for the licence.
    @ID(key: .id)
    public var id: UUID?

    /// The human-readable licence key (e.g. `FITO-XXXX-XXXX-XXXX-XXXX`).
    @Field(key: "key")
    public var key: String

    /// The user this licence belongs to, once linked to an account.
    @OptionalParent(key: "user_id")
    public var user: UserModel?

    /// The plan the licence was purchased under.
    @Enum(key: "plan")
    public var plan: LicensePlan

    /// The lifecycle status of the licence.
    @Enum(key: "status")
    public var status: LicenseStatus

    /// The maximum number of concurrently activated devices.
    @Field(key: "max_activations")
    public var maxActivations: Int

    /// For subscriptions: when the current billing period ends.
    @OptionalField(key: "expires_at")
    public var expiresAt: Date?

    /// Timestamp when the licence was created.
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?

    /// Timestamp when the licence was last updated.
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?

    /// Timestamp when the licence was deleted.
    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?

    /// Initializes a new instance of `LicenseModel`.
    public init() {}

    /// Initializes a new instance of `LicenseModel` with the provided parameters.
    public init(
        id: UUID? = nil,
        key: String,
        userID: UUID? = nil,
        plan: LicensePlan,
        status: LicenseStatus = .active,
        maxActivations: Int,
        expiresAt: Date? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.key = key
        self.plan = plan
        self.status = status
        self.maxActivations = maxActivations
        self.expiresAt = expiresAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        $user.id = userID
    }

    /// Converts the model to a `LicenseDTO`.
    public func toDTO() -> LicenseDTO {
        .init(
            id: id,
            key: key,
            userId: $user.id,
            plan: plan,
            status: status,
            maxActivations: maxActivations,
            createdAt: createdAt,
            updatedAt: updatedAt,
            expiresAt: expiresAt
        )
    }

    deinit {
        return
    }
}
