// ModelExtensions.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent
import Foundation

/// Extension on model to check if a specific row with id exists
internal extension Model {
    /// Extension on model to check if a specific row with id exists
    static func doesExist(id: UUID, on database: any Database) async throws -> Bool {
        try await query(on: database)
            .filter("id", .equal, id)
            .count() > 0
    }
}
