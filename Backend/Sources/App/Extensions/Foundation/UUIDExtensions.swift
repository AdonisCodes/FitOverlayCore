// UUIDExtensions.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

/// unwrap uuid from string & calls specific callback if error occurs
internal extension UUID {
    /// unwrap uuid from string & calls specific callback if error occurs
    static func unwrapFromString(_ uuidString: String, _ callback: () throws -> Void) throws -> UUID {
        guard
            let uuid = UUID(uuidString: uuidString)
        else {
            try callback()
            throw Abort(.internalServerError)
        }
        return uuid
    }
}
