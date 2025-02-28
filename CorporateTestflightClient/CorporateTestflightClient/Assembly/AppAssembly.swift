import CorporateTestflightDomain
import Foundation
import SimpleDI
import TestflightNetworking


final class AppAssembly: Assembly {

	let api: TestflightAPIProviding = TestflightAPIProvider(session: .shared, decoder: JSONDecoder())

	func assemble(container: SimpleDI.Container) {

		container.register((any VersionsRepository).self) {
			VersionsRepositoryImpl(api: self.api)
		}

		container.register((any ProjectsRepository).self) {
			ProjectsRepositoryImpl(api: self.api)
		}

		container.register((any TicketsRepository).self) {
			TicketsRepositoryImpl(api: self.api)
		}
	}
}
