// ActivityTrack.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import FitParser
import Foundation

/// A metric that can be displayed by an overlay widget and queried from a track.
public enum ActivityMetric: String, Codable, Sendable, CaseIterable {
    /// Speed in meters per second
    case speed
    /// Heart rate in beats per minute
    case heartRate
    /// Power in watts
    case power
    /// Cadence in revolutions per minute
    case cadence
    /// Elevation in meters
    case elevation
    /// Cumulative distance in meters
    case distance
    /// Grade in percent
    case grade
    /// Temperature in degrees Celsius
    case temperature
}

/// A single telemetry sample at a point in time.
public struct ActivitySample: Equatable, Sendable {
    /// Seconds since the start of the activity
    public var time: TimeInterval

    /// Metric values present in this sample
    public var values: [ActivityMetric: Double]

    /// GPS coordinate (latitude/longitude in degrees), when present
    public var coordinate: Coordinate?

    /// Initializes a sample.
    public init(time: TimeInterval, values: [ActivityMetric: Double] = [:], coordinate: Coordinate? = nil) {
        self.time = time
        self.values = values
        self.coordinate = coordinate
    }

    /// A platform-agnostic geographic coordinate.
    public struct Coordinate: Equatable, Codable, Sendable {
        /// Latitude in degrees
        public var latitude: Double
        /// Longitude in degrees
        public var longitude: Double

        /// Initializes a coordinate.
        public init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }
}

/// An immutable, time-ordered series of activity samples with lookup, interpolation,
/// and smoothing. This is the data source overlay widgets bind to.
public struct ActivityTrack: Equatable, Sendable {
    /// The absolute start date of the activity, when known
    public let startDate: Date?

    /// Samples ordered by `time`
    public let samples: [ActivitySample]

    /// Duration of the activity in seconds (0 for empty tracks)
    public var duration: TimeInterval {
        samples.last?.time ?? 0
    }

    /// Initializes a track from pre-built samples (sorted by time internally).
    public init(startDate: Date? = nil, samples: [ActivitySample]) {
        self.startDate = startDate
        self.samples = samples.sorted { $0.time < $1.time }
    }

    /// Builds a track from decoded FIT records.
    /// Records without timestamps are ignored; times are rebased so the first record is t=0.
    /// - Parameter records: Decoded `record` messages from `FitParser`
    public init(records: [FitRecord]) {
        let timestamped = records.compactMap { record -> (Date, FitRecord)? in
            guard let timestamp = record.timestamp else {
                return nil
            }
            return (timestamp, record)
        }
        .sorted { $0.0 < $1.0 }

        guard let start = timestamped.first?.0 else {
            self.init(startDate: nil, samples: [])
            return
        }

        let samples = timestamped.map { timestamp, record -> ActivitySample in
            var values: [ActivityMetric: Double] = [:]
            if let speed = record.speed { values[.speed] = speed }
            if let heartRate = record.heartRate { values[.heartRate] = Double(heartRate) }
            if let power = record.power { values[.power] = Double(power) }
            if let cadence = record.cadence { values[.cadence] = Double(cadence) }
            if let altitude = record.altitude { values[.elevation] = altitude }
            if let distance = record.distance { values[.distance] = distance }
            if let grade = record.grade { values[.grade] = grade }
            if let temperature = record.temperature { values[.temperature] = Double(temperature) }

            var coordinate: ActivitySample.Coordinate?
            if let latitude = record.latitude, let longitude = record.longitude {
                coordinate = .init(latitude: latitude, longitude: longitude)
            }

            return ActivitySample(
                time: timestamp.timeIntervalSince(start),
                values: values,
                coordinate: coordinate
            )
        }

        self.init(startDate: start, samples: samples)
    }

    // MARK: - Lookup & interpolation

    /// Returns the linearly interpolated value of a metric at a point in time.
    /// - Parameters:
    ///   - metric: The metric to query
    ///   - time: Seconds since activity start
    /// - Returns: The interpolated value, or nil when the metric has no samples around `time`
    public func value(of metric: ActivityMetric, at time: TimeInterval) -> Double? {
        let points = samples.compactMap { sample -> (TimeInterval, Double)? in
            guard let value = sample.values[metric] else {
                return nil
            }
            return (sample.time, value)
        }

        guard !points.isEmpty else {
            return nil
        }
        if time <= points[0].0 {
            return points[0].1
        }
        if let last = points.last, time >= last.0 {
            return last.1
        }

        // Binary search for the surrounding pair.
        var low = 0
        var high = points.count - 1
        while high - low > 1 {
            let mid = (low + high) / 2
            if points[mid].0 <= time {
                low = mid
            } else {
                high = mid
            }
        }

        let (t0, v0) = points[low]
        let (t1, v1) = points[high]
        guard t1 > t0 else {
            return v0
        }
        let fraction = (time - t0) / (t1 - t0)
        return v0 + (v1 - v0) * fraction
    }

    /// Returns the interpolated coordinate at a point in time.
    /// - Parameter time: Seconds since activity start
    /// - Returns: The interpolated coordinate, or nil when no GPS data surrounds `time`
    public func coordinate(at time: TimeInterval) -> ActivitySample.Coordinate? {
        let points = samples.compactMap { sample -> (TimeInterval, ActivitySample.Coordinate)? in
            guard let coordinate = sample.coordinate else {
                return nil
            }
            return (sample.time, coordinate)
        }

        guard let first = points.first else {
            return nil
        }
        if time <= first.0 {
            return first.1
        }
        if let last = points.last, time >= last.0 {
            return last.1
        }

        var low = 0
        var high = points.count - 1
        while high - low > 1 {
            let mid = (low + high) / 2
            if points[mid].0 <= time {
                low = mid
            } else {
                high = mid
            }
        }

        let (t0, c0) = points[low]
        let (t1, c1) = points[high]
        guard t1 > t0 else {
            return c0
        }
        let fraction = (time - t0) / (t1 - t0)
        return .init(
            latitude: c0.latitude + (c1.latitude - c0.latitude) * fraction,
            longitude: c0.longitude + (c1.longitude - c0.longitude) * fraction
        )
    }

    /// Returns the min and max of a metric across the whole track.
    /// - Parameter metric: The metric to inspect
    /// - Returns: The (min, max) range, or nil when the metric has no samples
    public func range(of metric: ActivityMetric) -> (min: Double, max: Double)? {
        let values = samples.compactMap { $0.values[metric] }
        guard let minValue = values.min(), let maxValue = values.max() else {
            return nil
        }
        return (minValue, maxValue)
    }

    // MARK: - Smoothing

    /// Returns a copy of the track with one metric smoothed.
    /// - Parameters:
    ///   - metric: The metric to smooth
    ///   - smoother: The smoothing algorithm to apply
    /// - Returns: A new track with the smoothed metric values
    public func smoothed(_ metric: ActivityMetric, using smoother: MetricSmoother) -> ActivityTrack {
        let values = samples.map { $0.values[metric] }
        let smoothedValues = smoother.smooth(values)

        var newSamples = samples
        for index in newSamples.indices {
            if let value = smoothedValues[index] {
                newSamples[index].values[metric] = value
            }
        }
        return ActivityTrack(startDate: startDate, samples: newSamples)
    }
}
