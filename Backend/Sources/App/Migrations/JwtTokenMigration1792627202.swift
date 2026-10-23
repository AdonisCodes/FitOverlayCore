// JwtTokenMigration1792627202.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent

/// Migration to create the Jwt-Token schema, bound to the parent User object.
internal struct JwtTokenMigration1792627202: AsyncMigration {
    /// Prepares the migration by creating the Jwt-Token schema.
    /// - Parameter database: The database instance on which the migration is performed.
    /// - Throws: Throws an error if the schema creation fails.
    public func prepare(on database: Database) async throws {
        try await database.schema("Jwt-Token")
            .id()
            .field("token", .string, .required)
            .field("user_id", .uuid, .required)
            .field("subject", .string, .required)
            .field("updated_at", .datetime)
            .field("created_at", .datetime)
            .field("deleted_at", .datetime)
            .foreignKey(
                "user_id",
                references: "User",
                "id",
                onDelete: .cascade,
                name: "fk_jwt_token_user_id"
            )
            .create()
    }

    /// Reverts the migration by deleting the Jwt-Token schema.
    /// - Parameter database: The database instance on which the migration is reverted.
    /// - Throws: Throws an error if the schema deletion fails.
    public func revert(on database: Database) async throws {
        try await database.schema("Jwt-Token").delete()
    }
}
