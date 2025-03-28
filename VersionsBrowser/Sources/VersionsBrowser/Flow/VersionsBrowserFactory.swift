import SimpleDI
import VersionsBrowserInterface
import CorporateTestflightDomain

// Plan: 8
// Factory vs Resolver and actor isolation

@MainActor
protocol VersionsBrowserFactory {
	func environment(inputParameters: (VersionsBrowserFlowInput, @MainActor (VersionList.Environment.Output) -> Void)) -> VersionList.Environment
	func store(inputParameters: (VersionList.State, VersionList.Environment)) -> VersionsListStore
}

final class VersionsBrowserFactoryImpl: VersionsBrowserFactory {

	private let resolver: Resolver

	init(resolver: Resolver) {
		self.resolver = resolver
	}

	func environment(inputParameters: (VersionsBrowserFlowInput, @MainActor (VersionList.Environment.Output) -> Void)) -> VersionList.Environment {
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
}
