// TwitterOAuthTokenMigration1741687313.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent

/// Migration to create the Twitter-O-Auth-Token schema.
internal struct TwitterOAuthTokenMigration1741687313: AsyncMigration {
    /// Prepares the migration by creating the Twitter-O-Auth-Token schema.
    /// - Parameter database: The database instance on which the migration is performed.
    /// - Throws: Throws an error if the schema creation fails.
    public func prepare(on database: Database) async throws {
        try await database.schema("Twitter-O-Auth-Token")
            .id() // Add an ID field
            .field("updated_at", .datetime, .required) // Add a required updated_at timestamp field
            .field("created_at", .datetime, .required) // Add a required created_at timestamp field
            .field("deleted_at", .datetime) // Add a deleted_at timestamp field
            .field("oauth_token", .string, .required) // Add a required oauth_token field
            .field("oauth_token_secret", .string, .required) // Add a required oauth_token_secret field
            .field("oauth_callback_confirmed", .bool) // Add an oauth_callback_confirmed field
            .field("user_id", .uuid, .references("User", "id", onDelete: .cascade)) // Add a foreign key to User
            .create() // Create the schema
    }

    /// Reverts the migration by deleting the Twitter-O-Auth-Token schema.
    /// - Parameter database: The database instance on which the migration is reverted.
    /// - Throws: Throws an error if the schema deletion fails.
    public func revert(on database: Database) async throws {
        try await database.schema("Twitter-O-Auth-Token").delete()
    }
}
