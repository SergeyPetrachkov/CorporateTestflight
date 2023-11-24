import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor

// configures your application
@available(iOS 13.0.0, *)
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)

    app.migrations.add(CreateProjects())
    app.migrations.add(CreateTickets())
    app.migrations.add(CreateVersions())

    try await app.autoMigrate()
    // register routes
    try routes(app)
}
