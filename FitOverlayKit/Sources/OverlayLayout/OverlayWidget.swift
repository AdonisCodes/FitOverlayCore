// OverlayWidget.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import FitDataModel
import Foundation

/// A normalized point in overlay space. Both axes run 0...1 relative to the video frame
/// (0,0 = top-left), so layouts are resolution-independent.
public struct OverlayPoint: Equatable, Codable, Sendable {
    /// Horizontal position (0 = left, 1 = right)
    public var x: Double
    /// Vertical position (0 = top, 1 = bottom)
    public var y: Double

    /// Initializes a normalized point.
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

/// A normalized size in overlay space (fractions of the video frame).
public struct OverlaySize: Equatable, Codable, Sendable {
    /// Width as a fraction of the frame width
    public var width: Double
    /// Height as a fraction of the frame height
    public var height: Double

    /// Initializes a normalized size.
    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
}

/// Visual styling for a widget. Colors are hex strings (`#RRGGBB` or `#RRGGBBAA`) so the
/// model stays free of platform color types.
public struct OverlayStyle: Equatable, Codable, Sendable {
    /// Font size in points, relative to a 1080p frame (scaled at render time)
    public var fontSize: Double
    /// Font weight name (`regular`, `semibold`, `bold`)
    public var fontWeight: String
    /// Foreground color hex
    public var color: String
    /// Background color hex (nil = transparent)
    public var backgroundColor: String?
    /// Overall opacity 0...1
    public var opacity: Double
    /// Corner radius in points, relative to a 1080p frame
    public var cornerRadius: Double

    /// Initializes a style with sensible defaults.
    public init(
        fontSize: Double = 36,
        fontWeight: String = "semibold",
        color: String = "#FFFFFF",
        backgroundColor: String? = nil,
        opacity: Double = 1.0,
        cornerRadius: Double = 8
    ) {
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.color = color
        self.backgroundColor = backgroundColor
        self.opacity = opacity
        self.cornerRadius = cornerRadius
    }
}

/// The kinds of widgets the layout editor can place on the video.
public enum OverlayWidgetKind: String, Codable, Sendable, CaseIterable {
    /// Numeric readout of a bound metric (e.g. "34.2 km/h")
    case metricValue
    /// Circular gauge of a bound metric against its track range
    case gauge
    /// Elevation profile of the whole activity with a position marker
    case elevationProfile
    /// GPS track outline with a position marker
    case map
    /// Static user text (titles, athlete name)
    case text
    /// Current time / elapsed time readout
    case elapsedTime
}

/// How a widget's displayed unit is derived from its bound metric.
public enum OverlayUnitSystem: String, Codable, Sendable, CaseIterable {
    /// Kilometers, meters, °C
    case metric
    /// Miles, feet, °F
    case imperial
}

/// A single widget placed on the overlay canvas.
/// Widgets are pure data: position/size/style plus an optional data binding. The render
/// module resolves them against an `ActivityTrack` per frame; the layout editor mutates them.
public struct OverlayWidget: Equatable, Codable, Identifiable, Sendable {
    /// Stable identity of the widget within a project
    public var id: UUID

    /// What the widget displays
    public var kind: OverlayWidgetKind

    /// Normalized top-left position
    public var position: OverlayPoint

    /// Normalized size
    public var size: OverlaySize

    /// Visual styling
    public var style: OverlayStyle

    /// The metric this widget is bound to (nil for `text`)
    public var dataBinding: ActivityMetric?

    /// Static text content for `text` widgets; label override for metric widgets
    public var text: String?

    /// Smoothing applied to the bound metric before display
    public var smoothing: MetricSmoother?

    /// Initializes a widget.
    public init(
        id: UUID = UUID(),
        kind: OverlayWidgetKind,
        position: OverlayPoint,
        size: OverlaySize,
        style: OverlayStyle = .init(),
        dataBinding: ActivityMetric? = nil,
        text: String? = nil,
        smoothing: MetricSmoother? = nil
    ) {
        self.id = id
        self.kind = kind
        self.position = position
        self.size = size
        self.style = style
        self.dataBinding = dataBinding
        self.text = text
        self.smoothing = smoothing
    }
}
