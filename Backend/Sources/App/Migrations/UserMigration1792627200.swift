// UserMigration1792627200.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent
import PostgresKit
import Vapor

/// Migration to create the User schema.
internal struct UserMigration1792627200: AsyncMigration {
    public let logger: Logger = .init(label: "UserMigration1792627200")

    /// Prepares the migration by creating the User schema.
    /// - Parameter database: The database instance on which the migration is performed.
    /// - Throws: Throws an error if the schema creation fails.
    public func prepare(on database: Database) async throws {
        try await database.schema("User")
            .id()
            .field("username", .string, .required)
            .field("phone_number", .string, .required)
            .field("accepted", .bool, .required)
            .field("updated_at", .datetime, .required)
            .field("created_at", .datetime, .required)
            .field("deleted_at", .datetime)
            .unique(on: "username")
            .unique(on: "phone_number")
            .create()

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
