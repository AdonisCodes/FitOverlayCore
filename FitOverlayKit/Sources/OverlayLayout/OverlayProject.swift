// OverlayProject.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import FitDataModel
import Foundation
import OverlayTimeSync

/// A serialisable overlay document: the video + FIT file references, the time sync
/// between them, display preferences, and the widget layout. This is what the layout
/// editor edits and what gets saved to disk / shared as a template.
public struct OverlayProject: Equatable, Codable, Identifiable, Sendable {
    /// Current serialization format version, for forwards-compatible migration
    public static let currentFormatVersion = 1

    /// Stable project identity
    public var id: UUID

    /// Serialization format version of this document
    public var formatVersion: Int

    /// User-facing project name
    public var name: String

    /// File name / relative path of the source video (resolution handled by the host app)
    public var videoFileName: String?

    /// File name / relative path of the source .FIT file
    public var fitFileName: String?

    /// Mapping between video time and activity time
    public var timeSync: TimeSync

    /// Unit system used when formatting metric values
    public var unitSystem: OverlayUnitSystem

    /// The widgets placed on the canvas
    public var widgets: [OverlayWidget]

    /// Initializes a project.
    public init(
        id: UUID = UUID(),
        formatVersion: Int = OverlayProject.currentFormatVersion,
        name: String,
        videoFileName: String? = nil,
        fitFileName: String? = nil,
        timeSync: TimeSync = .init(),
        unitSystem: OverlayUnitSystem = .metric,
        widgets: [OverlayWidget] = []
    ) {
        self.id = id
        self.formatVersion = formatVersion
        self.name = name
        self.videoFileName = videoFileName
        self.fitFileName = fitFileName
        self.timeSync = timeSync
        self.unitSystem = unitSystem
        self.widgets = widgets
    }

    // MARK: - Serialization

    /// Encodes the project as pretty-printed JSON.
    /// - Returns: JSON data representing the project
    public func encodeToJSON() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }

    /// Decodes a project from JSON data.
    /// - Parameter data: JSON produced by `encodeToJSON`
    /// - Returns: The decoded project
    public static func decode(fromJSON data: Data) throws -> OverlayProject {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(OverlayProject.self, from: data)
    }

    // MARK: - Templates

    /// The default cycling/running template: speed + heart rate + power readouts along the
    /// bottom, elevation profile bottom-right, map top-right.
    public static func defaultTemplate(name: String = "Default") -> OverlayProject {
        OverlayProject(
            name: name,
            widgets: [
                OverlayWidget(
                    kind: .metricValue,
                    position: .init(x: 0.05, y: 0.85),
                    size: .init(width: 0.18, height: 0.10),
                    dataBinding: .speed,
                    text: "Speed",
                    smoothing: .movingAverage(window: 3)
                ),
                OverlayWidget(
                    kind: .metricValue,
                    position: .init(x: 0.28, y: 0.85),
                    size: .init(width: 0.18, height: 0.10),
                    style: .init(color: "#FD8B83"),
                    dataBinding: .heartRate,
                    text: "Heart Rate"
                ),
                OverlayWidget(
                    kind: .gauge,
                    position: .init(x: 0.51, y: 0.82),
                    size: .init(width: 0.12, height: 0.16),
                    dataBinding: .power,
                    text: "Power",
                    smoothing: .exponential(alpha: 0.3)
                ),
                OverlayWidget(
                    kind: .elevationProfile,
                    position: .init(x: 0.68, y: 0.85),
                    size: .init(width: 0.27, height: 0.10),
                    dataBinding: .elevation
                ),
                OverlayWidget(
                    kind: .map,
                    position: .init(x: 0.78, y: 0.05),
                    size: .init(width: 0.17, height: 0.25)
                ),
                OverlayWidget(
                    kind: .elapsedTime,
                    position: .init(x: 0.05, y: 0.05),
                    size: .init(width: 0.15, height: 0.07)
                ),
            ]
        )
    }
}
