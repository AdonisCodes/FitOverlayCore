// JwtTokenMigration1735121142.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent

/// Migration to create the Jwt-Token schema.
internal struct JwtTokenMigration1735121142: AsyncMigration {
    /// Prepares the migration by creating the Jwt-Token schema.
    /// - Parameter database: The database instance on which the migration is performed.
    /// - Throws: Throws an error if the schema creation fails.
    public func prepare(on database: Database) async throws {
        try await database.schema("Jwt-Token")
            .id() // Add an ID field
            .field("token", .string, .required) // Add a required token field
            .field("user_id", .uuid, .required) // Add a required user_id field
            .field("subject", .string, .required) // Add a required subject field
            .field("updated_at", .datetime) // Add an updated_at timestamp field
            .field("created_at", .datetime) // Add a created_at timestamp field
            .field("deleted_at", .datetime) // Add a deleted_at timestamp field
            .create() // Create the schema
    }

    /// Reverts the migration by deleting the Jwt-Token schema.
    /// - Parameter database: The database instance on which the migration is reverted.
    /// - Throws: Throws an error if the schema deletion fails.
    public func revert(on database: Database) async throws {
        try await database.schema("Jwt-Token").delete()
    }
}
