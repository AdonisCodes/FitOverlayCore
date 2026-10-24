// UserProfileAddProfilePictureMigration1735216565.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent

/// Migration to add a profile picture ID to the User schema.
internal struct UserProfileAddProfilePictureMigration1735216565: AsyncMigration {
    /// Prepares the migration by adding a profile_picture_id field to the User schema.
    /// - Parameter database: The database instance on which the migration is performed.
    /// - Throws: Throws an error if the schema update fails.
    public func prepare(on database: Database) async throws {
        try await database.schema("User")
            .field("profile_picture_id", .uuid) // Add a profile_picture_id field of type UUID
            .update() // Update the schema
    }

    /// Reverts the migration by removing the profile_picture_id field from the User schema.
    /// - Parameter database: The database instance on which the migration is reverted.
    /// - Throws: Throws an error if the schema update fails.
    public func revert(on database: Database) async throws {
        try await database.schema("User")
            .deleteField("profile_picture_id") // Remove the profile_picture_id field
            .update() // Update the schema
    }
}
