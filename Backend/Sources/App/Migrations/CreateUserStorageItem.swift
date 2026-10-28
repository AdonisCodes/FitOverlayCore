// CreateUserStorageItem.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent

/// Migration to create the user-storage schema.
internal struct CreateUserStorageItem: AsyncMigration {
    /// Prepares the migration by creating the user-storage schema.
    /// - Parameter database: The database instance on which the migration is performed.
    /// - Throws: Throws an error if the schema creation fails.
    public func prepare(on database: Database) async throws {
        try await database.schema("user-storage")
            .id() // Add an ID field
            .field("key", .string, .required) // Add a required key field
            .field("value", .string, .required) // Add a required value field
            .field("userId", .uuid) // Add a userId field of type UUID
            .field("created_at", .datetime) // Add a created_at timestamp field
            .field("updated_at", .datetime) // Add an updated_at timestamp field
            .create() // Create the schema
    }

    /// Reverts the migration by deleting the user-storage schema.
    /// - Parameter database: The database instance on which the migration is reverted.
    /// - Throws: Throws an error if the schema deletion fails.
    public func revert(on database: Database) async throws {
        try await database.schema("user-storage").delete()
    }
}
