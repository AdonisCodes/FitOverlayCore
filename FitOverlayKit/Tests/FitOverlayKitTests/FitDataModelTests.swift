// FitDataModelTests.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import FitDataModel
import FitParser
import Foundation
import Testing

@Suite("FitDataModelTests")
internal struct FitDataModelTests {
    private func makeTrack() -> ActivityTrack {
        ActivityTrack(samples: [
            .init(time: 0, values: [.speed: 2.0, .heartRate: 100]),
            .init(time: 10, values: [.speed: 4.0, .heartRate: 120]),
            .init(time: 20, values: [.speed: 6.0, .heartRate: 140]),
        ])
    }

    /// Values between samples should be linearly interpolated; values outside clamp.
    @Test("Linear interpolation")
    public func interpolation() throws {
        let track = makeTrack()

        #expect(track.value(of: .speed, at: 5) == 3.0)
        #expect(track.value(of: .speed, at: 0) == 2.0)
        #expect(track.value(of: .speed, at: -5) == 2.0)
        #expect(track.value(of: .speed, at: 100) == 6.0)
        #expect(track.value(of: .power, at: 5) == nil)
        #expect(track.duration == 20)
    }

    /// Building a track from FIT records should rebase times to t=0 and keep order.
    @Test("Track from FIT records")
    public func fromRecords() throws {
        var first = FitRecord()
        first.timestamp = FitRecord.date(fromFitTimestamp: 1_000)
        first.speed = 5.0
        var second = FitRecord()
        second.timestamp = FitRecord.date(fromFitTimestamp: 1_010)
        second.speed = 7.0

        // Intentionally unordered input
        let track = ActivityTrack(records: [second, first])

        #expect(track.samples.count == 2)
        #expect(track.samples[0].time == 0)
        #expect(track.samples[1].time == 10)
        #expect(track.value(of: .speed, at: 5) == 6.0)
    }

    /// Moving average smoothing should flatten spikes without changing series length.
    @Test("Moving average smoothing")
    public func movingAverage() throws {
        let samples = [1.0, 1.0, 10.0, 1.0, 1.0].enumerated().map { index, value in
            ActivitySample(time: Double(index), values: [.power: value])
        }
        let track = ActivityTrack(samples: samples)
        let smoothed = track.smoothed(.power, using: .movingAverage(window: 3))

        let peak = try #require(smoothed.value(of: .power, at: 2))
        #expect(peak == 4.0) // (1 + 10 + 1) / 3
        #expect(smoothed.samples.count == track.samples.count)
    }

    /// Exponential smoothing should lag toward new values.
    @Test("Exponential smoothing")
    public func exponential() {
        let smoother = MetricSmoother.exponential(alpha: 0.5)
        let smoothed = smoother.smooth([10, 20, nil, 30])

        #expect(smoothed[0] == 10)
        #expect(smoothed[1] == 15)
        #expect(smoothed[2] == nil)
        #expect(smoothed[3] == 22.5)
    }

    /// Range queries should report metric min/max.
    @Test("Metric range")
    public func range() throws {
        let track = makeTrack()
        let heartRange = try #require(track.range(of: .heartRate))
        #expect(heartRange.min == 100)
        #expect(heartRange.max == 140)
        #expect(track.range(of: .power) == nil)
    }

    /// GPS coordinates should interpolate between fixes.
    @Test("Coordinate interpolation")
    public func coordinates() throws {
        let track = ActivityTrack(samples: [
            .init(time: 0, coordinate: .init(latitude: 50.0, longitude: 6.0)),
            .init(time: 10, coordinate: .init(latitude: 51.0, longitude: 7.0)),
        ])
        let mid = try #require(track.coordinate(at: 5))
        #expect(abs(mid.latitude - 50.5) < 0.000_001)
        #expect(abs(mid.longitude - 6.5) < 0.000_001)
    }
}
