// AddAcceptedColumnMigration1740658649.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent

/// Migration to add an 'accepted' column to the User schema.
internal struct AddAcceptedColumnMigration1740658649: AsyncMigration {
    /// Prepares the migration by updating the User schema to include the 'accepted' column.
    /// - Parameter database: The database instance on which the migration is performed.
    /// - Throws: Throws an error if the schema update fails.
    public func prepare(on database: Database) async throws {
        try await database.schema("User")
            .field("accepted", .bool, .required) // Add the 'accepted' field of type boolean
            .update() // Apply the update to the schema
    }

    /// Reverts the migration by removing the 'accepted' column from the User schema.
    /// - Parameter database: The database instance on which the migration is reverted.
    /// - Throws: Throws an error if the schema update fails.
    public func revert(on database: Database) async throws {
        try await database.schema("User")
            .deleteField("accepted")
            .update()
    }
}
