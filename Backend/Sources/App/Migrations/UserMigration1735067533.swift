// UserMigration1735067533.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent
import PostgresKit
import Vapor

/// Migration to create the User schema.
internal struct UserMigration1735067533: AsyncMigration {
    public let logger: Logger = .init(label: "UserMigration1735067533")
    /// Prepares the migration by creating the User schema.
    /// - Parameter database: The database instance on which the migration is performed.
    /// - Throws: Throws an error if the schema creation fails.
    public func prepare(on database: Database) async throws {
        try await database.schema("User")
            .id() // Add an ID field
            .field("username", .string, .required) // Add a required username field
            .field("phone_number", .string, .required) // Add a required phone_number field
            .field("instagram_handle", .string) // Add an optional instagram_handle field
            .field("updated_at", .datetime, .required) // Add a required updated_at timestamp field
            .field("created_at", .datetime, .required) // Add a required created_at timestamp field
            .field("deleted_at", .datetime) // Add a deleted_at timestamp field
            .unique(on: "username") // Ensure username is unique
            .unique(on: "phone_number") // Ensure phone_number is unique
            .create() // Create the schema

        let sqlDB = try getSQLDatabase(database)
        try await sqlDB
            .create(index: "idx_user_by_username")
            .on("User")
            .column("username")
            .run()
    }

    /// Reverts the migration by deleting the User schema and its index.
    /// - Parameter database: The database instance on which the migration is reverted.
    /// - Throws: Throws an error if the schema deletion fails.
    public func revert(on database: Database) async throws {
        try await database.schema("User").delete()
        let sqlDB = try getSQLDatabase(database)
        try await sqlDB.drop(index: "idx_user_by_username").run()
    }

    private func getSQLDatabase(_ database: Database) throws -> SQLDatabase {
        guard
            let sqlDB = database as? SQLDatabase
        else {
            logger.error(
                "Could not convert database to SQLDatabase"
            )
            throw Abort(.internalServerError)
        }
        return sqlDB
    }
}
