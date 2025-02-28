import CorporateTestflightDomain
import Foundation
import SimpleDI
import TestflightNetworking

final class AppAssembly: Assembly {

	func assemble(container: SimpleDI.Container) {

		container.registerSingleton((any TestflightAPIProviding).self) { _,_ in
			TestflightAPIProvider(session: .shared, decoder: JSONDecoder())
		}

		container.register((any VersionsRepository).self) { _, resolver -> VersionsRepositoryImpl in
			guard let api = resolver.resolve(TestflightAPIProviding.self) else {
				fatalError("My self-written DI sucks!")
			}
			return VersionsRepositoryImpl(api: api)
		}

		container.register((any ProjectsRepository).self) { _, resolver in
			guard let api = resolver.resolve(TestflightAPIProviding.self) else {
				fatalError("My self-written DI sucks!")
			}
			return ProjectsRepositoryImpl(api: api)
		}

		container.register((any TicketsRepository).self) { _, resolver in
			guard let api = resolver.resolve(TestflightAPIProviding.self) else {
				fatalError("My self-written DI sucks!")
			}
			return TicketsRepositoryImpl(api: api)
		}
	}
}
