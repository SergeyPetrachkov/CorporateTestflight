import Fluent
import Vapor

struct ImagesController: RouteCollection {

	func boot(routes: RoutesBuilder) throws {
		let tickets = routes.grouped("images")
		tickets.group(":name") { ticket in
			ticket.get(use: show)
		}
	}

	func show(req: Request) async throws -> Response {
		guard
			let imageName = req.parameters.get("name")
		else {
			throw Abort(.badRequest)
		}

		let res = try await req
			.fileio
			.asyncStreamFile(
				at: req
					.application
					.directory
					.publicDirectory
					.appending(imageName)
			)
		return res
	}
}
