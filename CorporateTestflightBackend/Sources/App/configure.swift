import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor

// configures your application
@available(iOS 13.0.0, *)
public func configure(_ app: Application) async throws {

	app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

	app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)

	app.migrations.add(CreateProjects())
	app.migrations.add(CreateTickets(dataUrl: app.directory.publicDirectory.appending("tickets.json")))
	app.migrations.add(CreateVersions(dataUrl: app.directory.publicDirectory.appending("versions.json")))

	try await app.autoMigrate()
	// register routes
	try routes(app)
}
