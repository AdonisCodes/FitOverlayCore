// NetworkManager.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Foundation
import Network

/// A class that monitors network connectivity status.
/// This class is thread-safe and can be used across multiple threads.
/// It provides real-time updates about the device's network connection status.
public class NetworkManager: ObservableObject, @unchecked Sendable {
    /// The network path monitor instance used to observe network status changes
    public let monitor = NWPathMonitor()

    /// A dedicated dispatch queue for handling network monitoring operations
    public let queue = DispatchQueue(label: "NetworkManager")

    /// A boolean value indicating whether the device is currently connected to the network
    /// - true: Device has network connectivity
    /// - false: Device has no network connectivity
    public var isConnected = true

    /// Initializes a new NetworkManager instance and starts monitoring network status
    /// This will begin observing network changes immediately upon initialization
    public init() {
        // Configure the path update handler to respond to network status changes
        monitor.pathUpdateHandler = { path in
            // Ensure UI updates happen on the main thread
            DispatchQueue.main.async { [self] in
                Task {
                    // Update the connection status and notify observers on the main actor
                    await MainActor.run {
                        self.isConnected = path.status == .satisfied
                        self.objectWillChange.send()
                    }
                }
            }
        }

        // Start monitoring network status on the dedicated queue
        monitor.start(queue: queue)
    }

    /// Cleanup method called when the NetworkManager instance is being deallocated
    deinit {
        return
    }
}
