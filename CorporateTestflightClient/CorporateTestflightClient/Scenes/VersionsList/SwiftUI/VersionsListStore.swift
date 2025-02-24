import Combine
import CorporateTestflightDomain
import UniFlow

final class VersionsListStore: ObservableObject, Store {

	typealias State = VersionList.State
	typealias Environment = VersionList.Environment
	typealias Action = VersionList.Action

	private(set) var environment: VersionList.Environment

	@Published private(set) var state: State {
		didSet {
			print("state >> '\(state)'")
		}
	}

	private var versions: [Version] = []

	init(initialState: State = .initial, environment: Environment) {
		self.state = initialState
		self.environment = environment
	}

	func send(_ action: VersionList.Action) async {
		print("'action: \(action)' >> 'state: \(state)'")
		switch action {
		case .start:
			guard case .initial = state else {
				return // we don't start multiple times
			}
			await loadData(enterLoadingState: true)
		case .refresh(let fromScratch):
			await loadData(enterLoadingState: fromScratch)
		case .tapItem(let rowState):
			guard let version = versions.first(where: { $0.id == rowState.id }) else {
				return
			}
			environment.output(.selectedVersion(version))
		}
	}

	private func loadData(enterLoadingState: Bool) async {
		do {
			if enterLoadingState {
				state = .loading
			}
			let (project, builds) = try await environment.usecase.execute(projectId: environment.project)
			let mappedContent = await map(project: project, versions: builds)
			versions = builds
			state = .loaded(mappedContent)
		} catch {
			state = .failed(error)
		}
	}

	nonisolated private func map(project: Project, versions: [Version]) async -> VersionList.State.Content {
		let rows = await environment.mapper.map(versions: versions)
		return .init(projectTitle: project.name, versions: rows)
	}
}
