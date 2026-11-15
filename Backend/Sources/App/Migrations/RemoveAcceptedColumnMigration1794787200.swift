// RemoveAcceptedColumnMigration1794787200.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent

/// Migration to drop the account-approval column from the User schema.
internal struct RemoveAcceptedColumnMigration1794787200: AsyncMigration {
    /// Removes the `accepted` column. New accounts are not reviewed.
    /// - Parameter database: The database instance on which the migration is performed.
    /// - Throws: Throws an error if the schema update fails.
    public func prepare(on database: Database) async throws {
        try await database.schema("User")
            .deleteField("accepted")
            .update()
    }

    /// Restores the `accepted` column.
    /// - Parameter database: The database instance on which the migration is reverted.
    /// - Throws: Throws an error if the schema update fails.
    public func revert(on database: Database) async throws {
        try await database.schema("User")
            .field("accepted", .bool, .required)
            .update()
    }
}
