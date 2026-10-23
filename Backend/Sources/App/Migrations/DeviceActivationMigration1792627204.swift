// DeviceActivationMigration1792627204.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent

/// Migration to create the Device-Activation schema.
internal struct DeviceActivationMigration1792627204: AsyncMigration {
    /// Prepares the migration by creating the Device-Activation schema.
    /// - Parameter database: The database instance on which the migration is performed.
    /// - Throws: Throws an error if the schema creation fails.
    public func prepare(on database: Database) async throws {
        try await database.schema("Device-Activation")
            .id()
            .field("license_id", .uuid, .required, .references("License", "id", onDelete: .cascade))
            .field("device_identifier", .string, .required)
            .field("device_name", .string, .required)
            .field("platform", .string, .required)
            .field("updated_at", .datetime)
            .field("created_at", .datetime)
            .field("deleted_at", .datetime)
            .unique(on: "license_id", "device_identifier")
            .create()
    }

    /// Reverts the migration by deleting the Device-Activation schema.
    /// - Parameter database: The database instance on which the migration is reverted.
    /// - Throws: Throws an error if the schema deletion fails.
    public func revert(on database: Database) async throws {
        try await database.schema("Device-Activation").delete()
    }
}
