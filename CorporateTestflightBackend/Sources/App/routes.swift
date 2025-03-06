import Fluent
import Vapor

func routes(_ app: Application) throws {
	app.get { req async in
		"It works!"
	}

	app.get("hello") { req async -> String in
		"Hello, world!"
	}

	try app.register(collection: ProjectsController())
	try app.register(collection: VersionsController())
	try app.register(collection: TicketsController())
	try app.register(collection: ImagesController())
}

