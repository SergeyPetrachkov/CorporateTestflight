import CorporateTestflightDomain
import Foundation
import SimpleDI
import TestflightNetworking
import ImageLoader
import Client

// Plan: 2. AppAssembly, a place where we register all the dependencies.

final class AppAssembly: Assembly {

	func assemble(container: SimpleDI.Container) {

		container.registerSingleton((any TestflightAPIProviding).self) { _, _ in
			TestflightAPIProvider(session: .shared, decoder: JSONDecoder())
		}

		container.registerSingleton((any ImageLoader).self) { _, resolver in
			guard let api = resolver.resolve((any TestflightAPIProviding).self) else {
				fatalError("My self-written DI sucks!")
			}
			return ImageCache(apiService: api)
		}

		container.register((any VersionsRepository).self) { _, resolver -> VersionsRepositoryImpl in
			guard let api = resolver.resolve((any TestflightAPIProviding).self) else {
				fatalError("My self-written DI sucks!")
			}
			return VersionsRepositoryImpl(api: api)
		}

		container.register((any ProjectsRepository).self) { _, resolver in
			guard let api = resolver.resolve((any TestflightAPIProviding).self) else {
				fatalError("My self-written DI sucks!")
			}
			return ProjectsRepositoryImpl(api: api)
		}

		container.registerSingleton((any TicketsRepository).self) { _, resolver in
			guard let api = resolver.resolve((any TestflightAPIProviding).self) else {
				fatalError("My self-written DI sucks!")
			}
			return TicketsCacheActor(repository: TicketsRepositoryImpl(api: api))
		}
	}
}
