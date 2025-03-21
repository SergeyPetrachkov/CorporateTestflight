import SimpleDI
import VersionsBrowserInterface
import CorporateTestflightDomain

@MainActor
public final class VersionsBrowserAssembly: @preconcurrency Assembly {

	public init() {}

	public func assemble(container: SimpleDI.Container) {
		container.register((any VersionsBrowserCoordinator).self) { input, resolver in
			VersionsListCoordinator(input: input, factory: VersionsBrowserFactoryImpl(resolver: resolver))
		}
	}
}

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
