// OverlayFrameRenderer.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import FitDataModel
import Foundation
import OverlayLayout
import OverlayTimeSync

/// An absolute rectangle in output pixel space.
public struct OverlayRect: Equatable, Sendable {
    /// X of the top-left corner in pixels
    public var x: Double
    /// Y of the top-left corner in pixels
    public var y: Double
    /// Width in pixels
    public var width: Double
    /// Height in pixels
    public var height: Double

    /// Initializes a rectangle.
    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}

/// A platform-agnostic draw command. Host apps translate these into SwiftUI/CoreGraphics,
/// Direct2D, Canvas/WebGL, or an ffmpeg filter graph — the engine never touches a
/// platform drawing API itself.
public enum OverlayElement: Equatable, Sendable {
    /// Draw text inside a rect
    case text(string: String, rect: OverlayRect, style: OverlayStyle)
    /// Draw a radial gauge: `progress` 0...1 of the metric within `range`
    case gauge(label: String, valueText: String, progress: Double, rect: OverlayRect, style: OverlayStyle)
    /// Draw a polyline of normalized points (0...1 within `rect`) with a highlighted marker
    case path(points: [OverlayPoint], markerIndex: Int?, rect: OverlayRect, style: OverlayStyle)
}

/// One fully resolved overlay frame, ready to be drawn over a video frame.
public struct OverlayFrame: Equatable, Sendable {
    /// Video time this frame was resolved for
    public let videoTime: TimeInterval
    /// Activity time the widgets were sampled at
    public let activityTime: TimeInterval
    /// Draw commands in z-order
    public let elements: [OverlayElement]

    /// Initializes a resolved frame.
    public init(videoTime: TimeInterval, activityTime: TimeInterval, elements: [OverlayElement]) {
        self.videoTime = videoTime
        self.activityTime = activityTime
        self.elements = elements
    }
}

/// Resolves an `OverlayProject` against an `ActivityTrack` into per-frame draw commands.
///
/// Usage:
/// ```swift
/// let renderer = OverlayFrameRenderer(project: project, track: track)
/// let frame = renderer.renderFrame(atVideoTime: 12.5, width: 1920, height: 1080)
/// ```
public struct OverlayFrameRenderer {
    /// The project being rendered
    public let project: OverlayProject

    /// The telemetry track, with per-widget smoothing pre-applied
    public let track: ActivityTrack

    private let smoothedTracks: [UUID: ActivityTrack]

    /// Initializes a renderer, pre-computing smoothed tracks for widgets that request smoothing.
    /// - Parameters:
    ///   - project: The overlay project to render
    ///   - track: The decoded activity telemetry
    public init(project: OverlayProject, track: ActivityTrack) {
        self.project = project
        self.track = track

        var smoothed: [UUID: ActivityTrack] = [:]
        for widget in project.widgets {
            if let smoothing = widget.smoothing, let metric = widget.dataBinding {
                smoothed[widget.id] = track.smoothed(metric, using: smoothing)
            }
        }
        smoothedTracks = smoothed
    }

    /// Resolves all widgets for a single video frame.
    /// - Parameters:
    ///   - videoTime: Seconds since the start of the video
    ///   - width: Output width in pixels
    ///   - height: Output height in pixels
    /// - Returns: The resolved overlay frame
    public func renderFrame(atVideoTime videoTime: TimeInterval, width: Double, height: Double) -> OverlayFrame {
        let activityTime = project.timeSync.activityTime(forVideoTime: videoTime)

        let elements = project.widgets.compactMap { widget in
            resolve(widget: widget, activityTime: activityTime, width: width, height: height)
        }

        return OverlayFrame(videoTime: videoTime, activityTime: activityTime, elements: elements)
    }

    // MARK: - Widget resolution

    private func resolve(
        widget: OverlayWidget,
        activityTime: TimeInterval,
        width: Double,
        height: Double
    ) -> OverlayElement? {
        let rect = OverlayRect(
            x: widget.position.x * width,
            y: widget.position.y * height,
            width: widget.size.width * width,
            height: widget.size.height * height
        )
        let widgetTrack = smoothedTracks[widget.id] ?? track

        switch widget.kind {
        case .text:
            guard let text = widget.text else {
                return nil
            }
            return .text(string: text, rect: rect, style: widget.style)

        case .elapsedTime:
            return .text(
                string: Self.formatElapsedTime(max(0, activityTime)),
                rect: rect,
                style: widget.style
            )

        case .metricValue:
            guard let metric = widget.dataBinding else {
                return nil
            }
            let value = widgetTrack.value(of: metric, at: activityTime)
            let valueText = MetricFormatter.format(value: value, metric: metric, unitSystem: project.unitSystem)
            let label = widget.text ?? MetricFormatter.defaultLabel(for: metric)
            return .text(string: "\(label): \(valueText)", rect: rect, style: widget.style)

        case .gauge:
            guard let metric = widget.dataBinding else {
                return nil
            }
            let value = widgetTrack.value(of: metric, at: activityTime)
            let range = widgetTrack.range(of: metric)
            let progress: Double = {
                guard let value, let range, range.max > range.min else {
                    return 0
                }
                return (value - range.min) / (range.max - range.min)
            }()
            return .gauge(
                label: widget.text ?? MetricFormatter.defaultLabel(for: metric),
                valueText: MetricFormatter.format(value: value, metric: metric, unitSystem: project.unitSystem),
                progress: min(max(progress, 0), 1),
                rect: rect,
                style: widget.style
            )

        case .elevationProfile:
            return resolveElevationProfile(widget: widget, track: widgetTrack, activityTime: activityTime, rect: rect)

        case .map:
            return resolveMap(widget: widget, track: widgetTrack, activityTime: activityTime, rect: rect)
        }
    }

    private func resolveElevationProfile(
        widget: OverlayWidget,
        track: ActivityTrack,
        activityTime: TimeInterval,
        rect: OverlayRect
    ) -> OverlayElement? {
        let elevationPoints = track.samples.compactMap { sample -> (TimeInterval, Double)? in
            guard let elevation = sample.values[.elevation] else {
                return nil
            }
            return (sample.time, elevation)
        }
        guard elevationPoints.count >= 2,
              let first = elevationPoints.first,
              let last = elevationPoints.last,
              last.0 > first.0
        else {
            return nil
        }

        let elevations = elevationPoints.map(\.1)
        guard let minElevation = elevations.min(), let maxElevation = elevations.max() else {
            return nil
        }
        let elevationSpan = max(maxElevation - minElevation, 1)

        let points = elevationPoints.map { time, elevation in
            OverlayPoint(
                x: (time - first.0) / (last.0 - first.0),
                y: 1 - (elevation - minElevation) / elevationSpan
            )
        }

        let markerIndex = nearestIndex(in: elevationPoints.map(\.0), to: activityTime)
        return .path(points: points, markerIndex: markerIndex, rect: rect, style: widget.style)
    }

    private func resolveMap(
        widget: OverlayWidget,
        track: ActivityTrack,
        activityTime: TimeInterval,
        rect: OverlayRect
    ) -> OverlayElement? {
        let coordinates = track.samples.compactMap { sample -> (TimeInterval, ActivitySample.Coordinate)? in
            guard let coordinate = sample.coordinate else {
                return nil
            }
            return (sample.time, coordinate)
        }
        guard coordinates.count >= 2 else {
            return nil
        }

        let latitudes = coordinates.map(\.1.latitude)
        let longitudes = coordinates.map(\.1.longitude)
        guard let minLat = latitudes.min(), let maxLat = latitudes.max(),
              let minLon = longitudes.min(), let maxLon = longitudes.max()
        else {
            return nil
        }
        let latSpan = max(maxLat - minLat, 0.000_001)
        let lonSpan = max(maxLon - minLon, 0.000_001)

        let points = coordinates.map { _, coordinate in
            OverlayPoint(
                x: (coordinate.longitude - minLon) / lonSpan,
                y: 1 - (coordinate.latitude - minLat) / latSpan
            )
        }

        let markerIndex = nearestIndex(in: coordinates.map(\.0), to: activityTime)
        return .path(points: points, markerIndex: markerIndex, rect: rect, style: widget.style)
    }

    private func nearestIndex(in times: [TimeInterval], to target: TimeInterval) -> Int? {
        guard !times.isEmpty else {
            return nil
        }
        var bestIndex = 0
        var bestDistance = abs(times[0] - target)
        for (index, time) in times.enumerated() {
            let distance = abs(time - target)
            if distance < bestDistance {
                bestDistance = distance
                bestIndex = index
            }
        }
        return bestIndex
    }

    // MARK: - Formatting helpers

    /// Formats elapsed seconds as `H:MM:SS` or `MM:SS`.
    /// - Parameter elapsed: Elapsed seconds
    /// - Returns: The formatted string
    public static func formatElapsedTime(_ elapsed: TimeInterval) -> String {
        let total = Int(elapsed.rounded())
        let hours = total / 3_600
        let minutes = (total % 3_600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

/// Formats metric values with units for display on the overlay.
public enum MetricFormatter {
    /// Returns the default widget label for a metric.
    public static func defaultLabel(for metric: ActivityMetric) -> String {
        switch metric {
        case .speed: "Speed"
        case .heartRate: "Heart Rate"
        case .power: "Power"
        case .cadence: "Cadence"
        case .elevation: "Elevation"
        case .distance: "Distance"
        case .grade: "Grade"
        case .temperature: "Temperature"
        }
    }

    /// Formats a metric value (SI units in, display string out).
    /// - Parameters:
    ///   - value: The raw value in SI units (speed m/s, elevation m, ...)
    ///   - metric: The metric being formatted
    ///   - unitSystem: Metric or imperial display units
    /// - Returns: The formatted value with unit suffix, or `--` when nil
    public static func format(value: Double?, metric: ActivityMetric, unitSystem: OverlayUnitSystem) -> String {
        guard let value else {
            return "--"
        }

        switch (metric, unitSystem) {
        case (.speed, .metric):
            return String(format: "%.1f km/h", value * 3.6)
        case (.speed, .imperial):
            return String(format: "%.1f mph", value * 2.236_94)
        case (.heartRate, _):
            return String(format: "%.0f bpm", value)
        case (.power, _):
            return String(format: "%.0f W", value)
        case (.cadence, _):
            return String(format: "%.0f rpm", value)
        case (.elevation, .metric):
            return String(format: "%.0f m", value)
        case (.elevation, .imperial):
            return String(format: "%.0f ft", value * 3.280_84)
        case (.distance, .metric):
            return String(format: "%.2f km", value / 1_000)
        case (.distance, .imperial):
            return String(format: "%.2f mi", value / 1_609.344)
        case (.grade, _):
            return String(format: "%.1f %%", value)
        case (.temperature, .metric):
            return String(format: "%.0f °C", value)
        case (.temperature, .imperial):
            return String(format: "%.0f °F", value * 9 / 5 + 32)
        }
    }
}
