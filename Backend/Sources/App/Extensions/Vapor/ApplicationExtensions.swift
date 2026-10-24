// ApplicationExtensions.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Temporal
import Vapor

internal extension Application {
    var temporalClient: TemporalClient {
        let hostname = try! TemporalClient.getServerHostnameFromEnv()
        return try! TemporalClient(
            target: .dns(
                host: hostname,
                port: 7_233
            ),
            transportSecurity: .plaintext,
            configuration: .init(instrumentation: .init(serverHostname: hostname)),
            logger: Logger(label: "temporal-client")
        )
    }
}
