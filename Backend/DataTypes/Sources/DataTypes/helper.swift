// helper.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

/// Extension to Vapor's Content protocol providing JSON encoding and decoding utilities
public extension Content {
    /// Converts the content object to a dictionary representation
    /// - Returns: A dictionary with string keys and sendable values
    /// - Throws: An Abort error if the conversion fails
    func encodeToDictionary() throws -> [String: any Sendable] {
        // First encode the object to JSON data
        let data = try JSONEncoder().encode(self)

        // Attempt to convert the JSON data to a dictionary
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: any Sendable]
        else {
            throw Abort(.internalServerError, reason: "Failed to convert DTO to dictionary")
        }
        return dictionary
    }

    /// Decodes JSON data into the conforming type
    /// - Parameter data: Optional Data object containing JSON
    /// - Returns: An instance of the conforming type
    /// - Throws: An Abort error if the data is nil or decoding fails
    static func decodeJSONFromData(data: Data?) throws -> Self {
        // Verify that data exists
        guard let data else {
            throw Abort(.badRequest, reason: "No data provided")
        }

        do {
            // Attempt to decode the data into the conforming type
            return try JSONDecoder().decode(Self.self, from: data)
        } catch {
            throw Abort(
                .internalServerError,
                reason: "Failed to decode JSON to \(Self.self): \(error.localizedDescription)"
            )
        }
    }

    /// Encodes the content object to JSON data
    /// - Returns: Data object containing the JSON representation
    /// - Throws: An error if encoding fails
    func encodeToData() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
