// LicenseMigration1792627203.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent

/// Migration to create the License schema.
internal struct LicenseMigration1792627203: AsyncMigration {
    /// Prepares the migration by creating the License schema.
    /// - Parameter database: The database instance on which the migration is performed.
    /// - Throws: Throws an error if the schema creation fails.
    public func prepare(on database: Database) async throws {
        try await database.schema("License")
            .id()
            .field("key", .string, .required)
            .field("user_id", .uuid, .references("User", "id", onDelete: .setNull))
            .field("plan", .string, .required)
            .field("status", .string, .required)
            .field("max_activations", .int, .required)
            .field("expires_at", .datetime)
            .field("updated_at", .datetime)
            .field("created_at", .datetime)
            .field("deleted_at", .datetime)
            .unique(on: "key")
            .create()
    }

    /// Reverts the migration by deleting the License schema.
    /// - Parameter database: The database instance on which the migration is reverted.
    /// - Throws: Throws an error if the schema deletion fails.
    public func revert(on database: Database) async throws {
        try await database.schema("License").delete()
    }
}
