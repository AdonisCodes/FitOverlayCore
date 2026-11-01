// configure.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import AutomaUtilities
import Fluent
import FluentPostgresDriver
import JWT
import Vapor

internal func configure(_ app: Application) async throws {
    registerCommands(app: app)
    let shouldSetupAPI = !["temporal-worker"].contains(CommandLine.arguments.last)
    if shouldSetupAPI {
        try await AppConfigurator(
            app: app,
            config: .init(
                shouldSetupAPI: true
            )
        ).configure()
    }
}

internal func registerCommands(app: Application) {
    app.asyncCommands.use(TemporalWorkerCommand(), as: "temporal-worker")
}

internal struct AppConfigurator {
    private let app: Application
    private let config: AppConfiguratorConfig
    private let environment = Environment.get("ENVIRONMENT") ?? "local"
    private let primaryDatabaseURL: String? = try? DatabaseURLs.primary.get()
    private let regionalDatabaseURL: String? = try? DatabaseURLs.regional.get()

    /// Initializes Application
    public init(app: Application, config: AppConfiguratorConfig) {
        self.app = app
        self.config = config
    }

    /// Configures the entire application
    public func configure() async throws {
        registerMiddleware()
        let hasDatabaseURLs = (primaryDatabaseURL != nil) || (regionalDatabaseURL != nil)
        if hasDatabaseURLs {
            try await configureWhenDatabaseURLsAvailable()
        }
    }

    private func registerMiddleware() {
        app.middleware.use(ErrorStringMiddleware())
    }

    private func configureWhenDatabaseURLsAvailable() async throws {
        try await DatabaseConfigurator(app: app).configureDatabases()
        try await startPrometheusService()

        app.logger.info("Should setup API: \(config.shouldSetupAPI). Environment: \(environment)")
        if config.shouldSetupAPI {
            try registerControllers()
            try await addAuthenticationJWTKey()
            try configureServer()
        }
    }

    private func registerControllers() throws {
        try app.register(collection: AuthenticationController())
        try app.register(collection: AppLaunchController())
        try app.register(collection: ChatCompletionController())
        try app.register(collection: LicenseController())
    }

    private func startPrometheusService() async throws {
        try await PrometheusService().startServer(port: config.metricsPort)
    }

    private func addAuthenticationJWTKey() async throws {
        let encryptionSecret = try Environment.getOrThrow("JWT_ENCRYPTION_SECRET")
        await app.jwt.keys.add(
            hmac: .init(stringLiteral: encryptionSecret), digestAlgorithm: .sha256)
    }

    private func configureServer() throws {
        app.http.server.configuration.responseCompression = .enabled
        app.lifecycle.use(TelemetryLifecycleHandler())
        app.middleware.use(TracingMiddleware())
    }

    public struct AppConfiguratorConfig {
        let shouldSetupAPI: Bool
        let metricsPort: UInt16

        init(shouldSetupAPI: Bool = true, metricsPort: UInt16 = 6_834) {
            self.shouldSetupAPI = shouldSetupAPI
            self.metricsPort = metricsPort
        }
    }
}

private struct TelemetryLifecycleHandler: LifecycleHandler {
    func shutdown(_ application: Application) {
        TelemetryExportService.shutdownTelemetry(timeout: 5)
        application.logger.info("Telemetry exporters shut down")
    }
}

internal struct DatabaseConfigurator {
    private let app: Application

    /// Initializes DB Configurator
    public init(app: Application) {
        self.app = app
    }

    /// Registers all migrations
    /// Sets up read & write databases
    /// Runs autoMigrate command
    public func configureDatabases() async throws {
        try registerDatabases()
        addMigrations()
        try await app.autoMigrate()
    }

    private func registerDatabases() throws {
        try app.databases.use(
            .postgres(
                url: DatabaseURLs.primary.get()
            ), as: .primary)

        try app.databases.use(
            .postgres(
                url: DatabaseURLs.regional.get()
            ), as: .readOnly)
    }

    private func addMigrations() {
        app.migrations.add(CreateUserStorageItem())
        app.migrations.add(UserMigration1735067533())
        app.migrations.add(AuthenticationCodeMigration1735069859())
        app.migrations.add(JwtTokenMigration1735121142())
        app.migrations.add(JWTTokenShouldBeBoundToParentUserObjectMigration1735140054())
        app.migrations.add(UserProfileAddProfilePictureMigration1735216565())
        app.migrations.add(UserProfileConvertIdToImageKeyMigration1735294202())
        app.migrations.add(RemoveUserStorageMigration1739456565())
        app.migrations.add(AddAcceptedColumnMigration1740658649())
        app.migrations.add(LicenseMigration1792627203())
        app.migrations.add(DeviceActivationMigration1792627204())
    }
}

/// Seed database with necessary data to run tests
public struct DatabaseSeeder {
    /// The main application
    public let app: Application

    /// Seed database
    public func seed() async throws {
        app.logger.info(
            "Seeding database.",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)")
            ]
        )
    }
}

internal enum DatabaseURLs {
    /// primary database url has read & write access
    public static let primary: Result<String, Error> = Result {
        try Environment.getOrThrow("PRIMARY_POSTGRES_URL")
    }
    /// regional url most likely doesn't have write access, but allows for extremely fast reads
    public static let regional: Result<String, Error> = Result {
        try Environment.getOrThrow("REGIONAL_POSTGRES_URL")
    }
}
