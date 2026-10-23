// MetricSmoother.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Foundation

/// Smoothing algorithms applied to metric series before display, so noisy sensor data
/// (e.g. raw power) reads nicely on the overlay.
public enum MetricSmoother: Equatable, Codable, Sendable {
    /// Centered moving average over `window` samples (window is clamped to odd ≥ 1)
    case movingAverage(window: Int)
    /// Exponential moving average with smoothing factor `alpha` in (0, 1]
    case exponential(alpha: Double)

    /// Smooths a series of optional values, preserving nil gaps.
    /// - Parameter values: The raw series (nil where the sample has no value for the metric)
    /// - Returns: The smoothed series, same length as the input
    public func smooth(_ values: [Double?]) -> [Double?] {
        switch self {
        case let .movingAverage(window):
            return smoothMovingAverage(values, window: window)
        case let .exponential(alpha):
            return smoothExponential(values, alpha: alpha)
        }
    }

    private func smoothMovingAverage(_ values: [Double?], window: Int) -> [Double?] {
        let window = max(1, window)
        let halfWindow = window / 2

        return values.indices.map { index -> Double? in
            guard values[index] != nil else {
                return nil
            }
            let lower = max(0, index - halfWindow)
            let upper = min(values.count - 1, index + halfWindow)
            let neighborhood = values[lower ... upper].compactMap(\.self)
            guard !neighborhood.isEmpty else {
                return nil
            }
            return neighborhood.reduce(0, +) / Double(neighborhood.count)
        }
    }

    private func smoothExponential(_ values: [Double?], alpha: Double) -> [Double?] {
        let alpha = min(max(alpha, 0.000_1), 1)
        var current: Double?

        return values.map { value -> Double? in
            guard let value else {
                return nil
            }
            if let previous = current {
                current = alpha * value + (1 - alpha) * previous
            } else {
                current = value
            }
            return current
        }
    }
}
