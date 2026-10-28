// JWTTokenShouldBeBoundToParentUserObjectMigration1735140054.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent

// swiftlint:disable type_name
/// Migration to bind JWT tokens to the parent User object.
internal struct JWTTokenShouldBeBoundToParentUserObjectMigration1735140054: AsyncMigration {
    // swiftlint:enable type_name
    /// Prepares the migration by adding a foreign key constraint to the Jwt-Token schema.
    /// - Parameter database: The database instance on which the migration is performed.
    /// - Throws: Throws an error if the schema update fails.
    public func prepare(on database: Database) async throws {
        try await database.schema("Jwt-Token")
            .foreignKey(
                "user_id",
                references: "User",
                "id",
                onDelete: .cascade,
                name: "fk_jwt_token_user_id"
            ) 
            .update()
    }

    /// Reverts the migration by removing the foreign key constraint from the Jwt-Token schema.
    /// - Parameter database: The database instance on which the migration is reverted.
    /// - Throws: Throws an error if the schema update fails.
    public func revert(on database: Database) async throws {
        try await database.schema("Jwt-Token")
            .deleteForeignKey(name: "fk_jwt_token_user_id")
            .update()
    }
}
