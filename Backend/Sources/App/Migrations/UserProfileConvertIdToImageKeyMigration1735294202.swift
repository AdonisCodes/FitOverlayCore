// UserProfileConvertIdToImageKeyMigration1735294202.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent

/// Migration to convert the profile picture ID to a profile picture key in the User schema.
internal struct UserProfileConvertIdToImageKeyMigration1735294202: AsyncMigration {
    /// Prepares the migration by updating the User schema.
    /// - Parameter database: The database instance on which the migration is performed.
    /// - Throws: Throws an error if the schema update fails.
    public func prepare(on database: Database) async throws {
        try await database.schema("User")
            .deleteField("profile_picture_id") // Remove the profile_picture_id field
            .field("profile_picture_key", .string) // Add the profile_picture_key field
            .update() // Apply the update to the schema
    }

    /// Reverts the migration by restoring the original User schema.
    /// - Parameter database: The database instance on which the migration is reverted.
    /// - Throws: Throws an error if the schema update fails.
    public func revert(on database: Database) async throws {
        try await database.schema("User")
            .deleteField("profile_picture_key") // Remove the profile_picture_key field
            .field("profile_picture_id", .uuid) // Restore the profile_picture_id field
            .update() // Apply the update to the schema
    }
}
