// TwitterUserTokenMigration1741708919.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent

/// Migration to create the Twitter-User-Token schema.
internal struct TwitterUserTokenMigration1741708919: AsyncMigration {
    /// Prepares the migration by creating the Twitter-User-Token schema.
    /// - Parameter database: The database instance on which the migration is performed.
    /// - Throws: Throws an error if the schema creation fails.
    public func prepare(on database: Database) async throws {
        try await database.schema("Twitter-User-Token")
            .id() // Add an ID field
            .field("updated_at", .datetime, .required) // Add a required updated_at timestamp field
            .field("created_at", .datetime, .required) // Add a required created_at timestamp field
            .field("deleted_at", .datetime) // Add a deleted_at timestamp field
            .field("access_token", .string, .required) // Add a required access_token field
            .field("secret_access_token", .string, .required) // Add a required secret_access_token field
            .field("oauth_verifier", .string, .required) // Add a required oauth_verifier field
            .field(
                "oauth_token_id",
                .uuid,
                .references("Twitter-O-Auth-Token", "id", onDelete: .cascade)
            ) // Add a foreign key to Twitter-O-Auth-Token
            .create() // Create the schema
    }

    /// Reverts the migration by deleting the Twitter-User-Token schema.
    /// - Parameter database: The database instance on which the migration is reverted.
    /// - Throws: Throws an error if the schema deletion fails.
    public func revert(on database: Database) async throws {
        try await database.schema("Twitter-User-Token").delete()
    }
}
