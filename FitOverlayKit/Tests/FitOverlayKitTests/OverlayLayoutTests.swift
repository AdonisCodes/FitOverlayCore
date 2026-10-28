// OverlayLayoutTests.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import FitDataModel
import Foundation
import OverlayLayout
import OverlayTimeSync
import Testing

@Suite("OverlayLayoutTests")
internal struct OverlayLayoutTests {
    /// Projects must survive a JSON encode/decode round trip unchanged.
    @Test("Project JSON round trip")
    public func jsonRoundTrip() throws {
        var project = OverlayProject.defaultTemplate(name: "Alpe d'Huez Run")
        project.videoFileName = "gopro-0042.mp4"
        project.fitFileName = "morning-ride.fit"
        project.timeSync = TimeSync(activityTimeAtVideoStart: 93.5, rateAdjustment: 1.0)
        project.unitSystem = .imperial

        let data = try project.encodeToJSON()
        let decoded = try OverlayProject.decode(fromJSON: data)

        #expect(decoded == project)
    }

    /// The default template must contain the core fitness widgets.
    @Test("Default template contents")
    public func defaultTemplate() {
        let template = OverlayProject.defaultTemplate()
        let kinds = Set(template.widgets.map(\.kind))

        #expect(kinds.contains(.metricValue))
        #expect(kinds.contains(.gauge))
        #expect(kinds.contains(.elevationProfile))
        #expect(kinds.contains(.map))
        #expect(kinds.contains(.elapsedTime))
        #expect(template.formatVersion == OverlayProject.currentFormatVersion)

        // All widgets must sit inside the normalized canvas.
        for widget in template.widgets {
            #expect(widget.position.x >= 0 && widget.position.x + widget.size.width <= 1)
            #expect(widget.position.y >= 0 && widget.position.y + widget.size.height <= 1)
        }
    }

    /// Time sync must map both directions consistently.
    @Test("Time sync mapping")
    public func timeSync() {
        let sync = TimeSync(activityTimeAtVideoStart: 120, rateAdjustment: 0.5)

        #expect(sync.activityTime(forVideoTime: 0) == 120)
        #expect(sync.activityTime(forVideoTime: 60) == 150)
        #expect(sync.videoTime(forActivityTime: 150) == 60)
    }
}
