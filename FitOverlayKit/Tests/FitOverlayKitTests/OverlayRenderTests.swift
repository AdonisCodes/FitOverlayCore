// OverlayRenderTests.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import FitDataModel
import Foundation
import OverlayLayout
import OverlayRender
import OverlayTimeSync
import Testing

@Suite("OverlayRenderTests")
internal struct OverlayRenderTests {
    private func makeTrack() -> ActivityTrack {
        ActivityTrack(samples: [
            .init(time: 0, values: [.speed: 5.0, .power: 100, .elevation: 800],
                  coordinate: .init(latitude: 45.0, longitude: 6.0)),
            .init(time: 10, values: [.speed: 10.0, .power: 200, .elevation: 850],
                  coordinate: .init(latitude: 45.01, longitude: 6.01)),
            .init(time: 20, values: [.speed: 15.0, .power: 300, .elevation: 900],
                  coordinate: .init(latitude: 45.02, longitude: 6.02)),
        ])
    }

    /// A metric widget should resolve into a text element with the interpolated value.
    @Test("Metric value rendering")
    public func metricValue() throws {
        let project = OverlayProject(
            name: "Test",
            widgets: [
                OverlayWidget(
                    kind: .metricValue,
                    position: .init(x: 0.5, y: 0.5),
                    size: .init(width: 0.2, height: 0.1),
                    dataBinding: .speed,
                    text: "Speed"
                ),
            ]
        )
        let renderer = OverlayFrameRenderer(project: project, track: makeTrack())
        let frame = renderer.renderFrame(atVideoTime: 5, width: 1_920, height: 1_080)

        #expect(frame.elements.count == 1)
        guard case let .text(string, rect, _) = frame.elements[0] else {
            Issue.record("Expected a text element")
            return
        }
        // 7.5 m/s = 27.0 km/h at t=5
        #expect(string == "Speed: 27.0 km/h")
        #expect(rect.x == 960)
        #expect(rect.y == 540)
        #expect(rect.width == 384)
    }

    /// Time sync offsets must shift which activity values are sampled.
    @Test("Time sync affects sampling")
    public func timeSyncSampling() throws {
        let project = OverlayProject(
            name: "Test",
            timeSync: .init(activityTimeAtVideoStart: 10),
            widgets: [
                OverlayWidget(
                    kind: .metricValue,
                    position: .init(x: 0, y: 0),
                    size: .init(width: 0.2, height: 0.1),
                    dataBinding: .power
                ),
            ]
        )
        let renderer = OverlayFrameRenderer(project: project, track: makeTrack())
        let frame = renderer.renderFrame(atVideoTime: 0, width: 1_000, height: 1_000)

        #expect(frame.activityTime == 10)
        guard case let .text(string, _, _) = frame.elements[0] else {
            Issue.record("Expected a text element")
            return
        }
        #expect(string == "Power: 200 W")
    }

    /// Gauges should report progress within the track's metric range.
    @Test("Gauge progress")
    public func gauge() throws {
        let project = OverlayProject(
            name: "Test",
            widgets: [
                OverlayWidget(
                    kind: .gauge,
                    position: .init(x: 0, y: 0),
                    size: .init(width: 0.1, height: 0.1),
                    dataBinding: .power
                ),
            ]
        )
        let renderer = OverlayFrameRenderer(project: project, track: makeTrack())
        let frame = renderer.renderFrame(atVideoTime: 10, width: 100, height: 100)

        guard case let .gauge(_, valueText, progress, _, _) = frame.elements[0] else {
            Issue.record("Expected a gauge element")
            return
        }
        #expect(valueText == "200 W")
        #expect(abs(progress - 0.5) < 0.000_001) // 200 within 100...300
    }

    /// Elevation and map widgets should produce normalized polylines with a marker.
    @Test("Path widgets")
    public func paths() throws {
        let project = OverlayProject(
            name: "Test",
            widgets: [
                OverlayWidget(
                    kind: .elevationProfile,
                    position: .init(x: 0, y: 0),
                    size: .init(width: 0.5, height: 0.2),
                    dataBinding: .elevation
                ),
                OverlayWidget(
                    kind: .map,
                    position: .init(x: 0.5, y: 0),
                    size: .init(width: 0.5, height: 0.5)
                ),
            ]
        )
        let renderer = OverlayFrameRenderer(project: project, track: makeTrack())
        let frame = renderer.renderFrame(atVideoTime: 20, width: 1_000, height: 1_000)

        #expect(frame.elements.count == 2)
        for element in frame.elements {
            guard case let .path(points, markerIndex, _, _) = element else {
                Issue.record("Expected a path element")
                return
            }
            #expect(points.count == 3)
            #expect(markerIndex == 2) // t=20 is the last sample
            for point in points {
                #expect(point.x >= 0 && point.x <= 1)
                #expect(point.y >= 0 && point.y <= 1)
            }
        }
    }

    /// Elapsed time should format as MM:SS / H:MM:SS.
    @Test("Elapsed time formatting")
    public func elapsedTime() {
        #expect(OverlayFrameRenderer.formatElapsedTime(65) == "01:05")
        #expect(OverlayFrameRenderer.formatElapsedTime(3_725) == "1:02:05")
    }

    /// Widgets with smoothing configured should sample the smoothed series.
    @Test("Smoothing applied in renderer")
    public func smoothingApplied() throws {
        let track = ActivityTrack(samples: [
            .init(time: 0, values: [.power: 100]),
            .init(time: 1, values: [.power: 400]),
            .init(time: 2, values: [.power: 100]),
        ])
        let project = OverlayProject(
            name: "Test",
            widgets: [
                OverlayWidget(
                    kind: .metricValue,
                    position: .init(x: 0, y: 0),
                    size: .init(width: 0.1, height: 0.1),
                    dataBinding: .power,
                    smoothing: .movingAverage(window: 3)
                ),
            ]
        )
        let renderer = OverlayFrameRenderer(project: project, track: track)
        let frame = renderer.renderFrame(atVideoTime: 1, width: 100, height: 100)

        guard case let .text(string, _, _) = frame.elements[0] else {
            Issue.record("Expected a text element")
            return
        }
        #expect(string == "Power: 200 W") // (100+400+100)/3
    }
}
