// AuthenticationCodeMigration1792627201.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent

/// Migration to create the Authentication-Code schema.
internal struct AuthenticationCodeMigration1792627201: AsyncMigration {
    /// Prepares the migration by creating the Authentication-Code schema.
    /// - Parameter database: The database instance on which the migration is performed.
    /// - Throws: Throws an error if the schema creation fails.
    public func prepare(on database: Database) async throws {
        try await database.schema("Authentication-Code")
            .id()
            .field("phone_number", .string, .required)
            .field("code", .string, .required)
            .field("updated_at", .datetime)
            .field("created_at", .datetime)
            .field("deleted_at", .datetime)
            .create()
    }

    /// Reverts the migration by deleting the Authentication-Code schema.
    /// - Parameter database: The database instance on which the migration is reverted.
    /// - Throws: Throws an error if the schema deletion fails.
    public func revert(on database: Database) async throws {
        try await database.schema("Authentication-Code").delete()
    }
}
