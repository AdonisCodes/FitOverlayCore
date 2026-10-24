// AuthenticationCodeMigration1735069859.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent

/// Migration to create the Authentication-Code schema.
internal struct AuthenticationCodeMigration1735069859: AsyncMigration {
    /// Prepares the migration by creating the Authentication-Code schema.
    /// - Parameter database: The database instance on which the migration is performed.
    /// - Throws: Throws an error if the schema creation fails.
    public func prepare(on database: Database) async throws {
        try await database.schema("Authentication-Code")
            .id() // Add an ID field
            .field("phone_number", .string, .required) // Add a required phone_number field
            .field("code", .string, .required) // Add a required code field
            .field("updated_at", .datetime) // Add an updated_at timestamp field
            .field("created_at", .datetime) // Add a created_at timestamp field
            .field("deleted_at", .datetime) // Add a deleted_at timestamp field
            .create() // Create the schema
    }

    /// Reverts the migration by deleting the Authentication-Code schema.
    /// - Parameter database: The database instance on which the migration is reverted.
    /// - Throws: Throws an error if the schema deletion fails.
    public func revert(on database: Database) async throws {
        try await database.schema("Authentication-Code").delete()
    }
}
