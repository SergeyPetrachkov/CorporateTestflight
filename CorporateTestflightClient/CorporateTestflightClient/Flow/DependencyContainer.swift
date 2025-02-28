import Foundation
import CorporateTestflightDomain
import TestflightNetworking

protocol DependencyContaining {

	var api: TestflightAPIProviding { get }

	var versionsRepository: VersionsRepository { get }

	var projectsRepository: ProjectsRepository { get }

	var ticketsRepository: TicketsRepository { get }

}

struct DependencyContainer: DependencyContaining {
	let api: any TestflightNetworking.TestflightAPIProviding
	
	let versionsRepository: any CorporateTestflightDomain.VersionsRepository

	let projectsRepository: any CorporateTestflightDomain.ProjectsRepository

	let ticketsRepository: any CorporateTestflightDomain.TicketsRepository
}

final class AppDependencies: DependencyContaining {

	private(set) lazy var api: TestflightAPIProviding = TestflightAPIProvider(session: .shared, decoder: JSONDecoder())

	var versionsRepository: VersionsRepository {
		VersionsRepositoryImpl(api: api)
	}

	var projectsRepository: ProjectsRepository {
		ProjectsRepositoryImpl(api: api)
	}

	var ticketsRepository: TicketsRepository {
		TicketsRepositoryImpl(api: api)
	}

	//    private(set) lazy var ticketsRepository: TicketsRepository = TicketsCacheActor(repository: TicketsRepositoryImpl(api: api))
}
