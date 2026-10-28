// TimeSync.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Foundation

/// Maps between video time and activity (FIT) time.
///
/// The common workflow: the action cam starts recording at a different moment than the
/// head unit starts the activity. The user aligns the two on a known event (e.g. the
/// moment they start moving), which produces `activityTimeAtVideoStart`. An optional
/// `rateAdjustment` compensates for clock drift or slow-motion footage.
public struct TimeSync: Equatable, Codable, Sendable {
    /// Activity time (seconds since activity start) when the video begins.
    /// Negative values mean the video started before the activity.
    public var activityTimeAtVideoStart: TimeInterval

    /// Playback rate multiplier between video time and real time.
    /// 1.0 for normal footage; e.g. 0.5 when the video is 2x slow motion.
    public var rateAdjustment: Double

    /// Initializes a time sync mapping.
    /// - Parameters:
    ///   - activityTimeAtVideoStart: Activity time at video t=0 (default 0)
    ///   - rateAdjustment: Video-to-real-time rate multiplier (default 1)
    public init(activityTimeAtVideoStart: TimeInterval = 0, rateAdjustment: Double = 1.0) {
        self.activityTimeAtVideoStart = activityTimeAtVideoStart
        self.rateAdjustment = rateAdjustment
    }

    /// Converts a video timestamp to activity time.
    /// - Parameter videoTime: Seconds since the start of the video
    /// - Returns: Seconds since the start of the activity
    public func activityTime(forVideoTime videoTime: TimeInterval) -> TimeInterval {
        activityTimeAtVideoStart + videoTime * rateAdjustment
    }

    /// Converts an activity timestamp to video time.
    /// - Parameter activityTime: Seconds since the start of the activity
    /// - Returns: Seconds since the start of the video
    public func videoTime(forActivityTime activityTime: TimeInterval) -> TimeInterval {
        guard rateAdjustment != 0 else {
            return 0
        }
        return (activityTime - activityTimeAtVideoStart) / rateAdjustment
    }
}
