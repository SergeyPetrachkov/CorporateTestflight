import SimpleDI
import VersionsBrowserInterface
import CorporateTestflightDomain
import JiraViewerInterface
import UIKit
import SwiftUI

protocol VersionsBrowserFactory {
	func environment(inputParameters: (VersionsBrowserFlowInput, (VersionList.Environment.Output) -> Void)) -> VersionList.Environment
	func store(inputParameters: (VersionList.State, VersionList.Environment)) -> VersionsListStore
	
	func versionDetailsController(inputParameters: (version: Version, onTicketTapped: (Ticket) -> Void)) -> UIViewController

	func jiraFlowCoordinator(inputParameters: JiraViewerFlowInput) -> any JiraViewerFlowCoordinating
}

final class VersionsBrowserFactoryImpl: VersionsBrowserFactory {

	private let resolver: Resolver

	init(resolver: Resolver) {
		self.resolver = resolver
	}

	func environment(inputParameters: (VersionsBrowserFlowInput, (VersionList.Environment.Output) -> Void)) -> VersionList.Environment {
		VersionsListStore.Environment(
			project: inputParameters.0.projectId,
			usecase: FetchProjectAndVersionsUsecaseImpl(
				versionsRepository: resolver.resolve(VersionsRepository.self)!,
				projectsRepository: resolver.resolve(ProjectsRepository.self)!
			),
			mapper: VersionList.RowMapper(),
			output: inputParameters.1
		)
	}

	func store(inputParameters: (VersionList.State, VersionList.Environment)) -> VersionsListStore {
		VersionsListStore(initialState: inputParameters.0, environment: inputParameters.1)
	}

	func versionDetailsController(inputParameters: (version: Version, onTicketTapped: (Ticket) -> Void)) -> UIViewController {
		let environment = VersionDetails.Environment(
			version: inputParameters.version,
			fetchTicketsUsecase: FetchTicketsUseCase(
				ticketsRepository: resolver.resolve(TicketsRepository.self)!
			),
			onTickedTapped: inputParameters.onTicketTapped
		)
		let store = VersionDetailsStore(
			initialState: .initial,
			environment: environment
		)
		let view = VersionDetailsContainer(store: store)
		return UIHostingController(rootView: view)
	}

	func jiraFlowCoordinator(inputParameters: JiraViewerFlowInput) -> any JiraViewerFlowCoordinating {
		resolver.resolve(
			(any JiraViewerFlowCoordinating).self,
			argument: inputParameters
		)!
	}
}
