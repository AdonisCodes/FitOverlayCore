// FitRecord.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Foundation

/// A single decoded `record` message (FIT global message number 20) — one sample of
/// workout telemetry. All values are converted to SI/display-friendly units.
public struct FitRecord: Equatable, Sendable {
    /// The FIT epoch (1989-12-31T00:00:00Z) as seconds since the Unix epoch.
    public static let fitEpochOffset: TimeInterval = 631_065_600

    /// Absolute timestamp of the sample
    public var timestamp: Date?

    /// Latitude in degrees (converted from semicircles)
    public var latitude: Double?

    /// Longitude in degrees (converted from semicircles)
    public var longitude: Double?

    /// Altitude in meters
    public var altitude: Double?

    /// Heart rate in beats per minute
    public var heartRate: Int?

    /// Cadence in revolutions per minute
    public var cadence: Int?

    /// Speed in meters per second
    public var speed: Double?

    /// Instantaneous power in watts
    public var power: Int?

    /// Cumulative distance in meters
    public var distance: Double?

    /// Grade in percent
    public var grade: Double?

    /// Temperature in degrees Celsius
    public var temperature: Int?

    /// Initializes an empty record
    public init() {}

    /// Converts a FIT timestamp (seconds since the FIT epoch) to a `Date`.
    /// - Parameter fitTimestamp: Seconds since 1989-12-31T00:00:00Z
    /// - Returns: The equivalent `Date`
    public static func date(fromFitTimestamp fitTimestamp: UInt32) -> Date {
        Date(timeIntervalSince1970: Double(fitTimestamp) + fitEpochOffset)
    }

    /// Converts semicircles (the FIT position unit) to degrees.
    /// - Parameter semicircles: The raw semicircle value
    /// - Returns: Degrees in the range -180...180
    public static func degrees(fromSemicircles semicircles: Int32) -> Double {
        Double(semicircles) * (180.0 / 2_147_483_648.0)
    }
}

/// The result of parsing a complete FIT file.
public struct FitFile: Equatable, Sendable {
    /// The decoded file header
    public let header: FitHeader

    /// All decoded `record` messages, in file order
    public let records: [FitRecord]

    /// Number of messages that were skipped (unknown or non-record message types)
    public let skippedMessageCount: Int

    /// Initializes a parsed FIT file result
    public init(header: FitHeader, records: [FitRecord], skippedMessageCount: Int) {
        self.header = header
        self.records = records
        self.skippedMessageCount = skippedMessageCount
    }
}
