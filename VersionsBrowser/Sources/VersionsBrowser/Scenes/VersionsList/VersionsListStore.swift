import Combine
import CorporateTestflightDomain
import UniFlow

// Plan:
// Implement Store
// Nonisolated async
// Cancellation Checks

final class VersionsListStore: ObservableObject, Store {

	typealias State = VersionList.State
	typealias Environment = VersionList.Environment
	typealias Action = VersionList.Action

	private(set) var environment: VersionList.Environment

	@Published var state: State

	private var versions: [Version] = []
	private var project: Project?

	init(initialState: State, environment: Environment) {
		self.state = initialState
		self.environment = environment
	}

	func send(_ action: VersionList.Action) async {
		print("'action: \(action)' >> 'state: \(state)'")
		switch action {
		case .start:
			await loadData(enterLoadingState: true)
		case .refresh(let fromScratch):
			await loadData(enterLoadingState: fromScratch)
		case .tapItem(let rowState):
			guard let version = versions.first(where: { $0.id == rowState.id }) else {
				return
			}
			environment.output(.selectedVersion(version))
		case .tapQR:
			environment.output(.qrRequested)
		case .search, .debouncedSearch:
			guard let project else {
				state.contentState = .failed(.init(localizedDescription: "No project is loaded. Try refreshing."))
				return
			}
			let filteredVersions = await filterVersions(searchTerm: state.seachTerm, versions: versions)
			let mappedContent = await map(project: project, versions: filteredVersions)
			state.contentState = .loaded(mappedContent)
		}
		print("state >> '\(state)'")
	}

	private func loadData(enterLoadingState: Bool) async {
		do {
			if enterLoadingState {
				state.contentState = .loading
			}
			let (project, builds) = try await environment.usecase.execute(projectId: environment.project)
			if Task.isCancelled {
				return
			}
			let mappedContent = await map(project: project, versions: builds)
			if Task.isCancelled {
				return
			}
			versions = builds
			self.project = project
			state.contentState = .loaded(mappedContent)
		} catch {
			state.contentState = .failed(.init(localizedDescription: error.localizedDescription))
		}
	}

	nonisolated private func map(project: Project, versions: [Version]) async -> VersionList.State.Content {
		let rows = await environment.mapper.map(versions: versions)
		return .init(projectTitle: project.name, versions: rows)
	}

	nonisolated private func filterVersions(searchTerm: String, versions: [Version]) async -> [Version] {
		guard !searchTerm.isEmpty else {
			return versions
		}
		let lowercasedSearchTerm = searchTerm.lowercased()
		return versions.filter {
			$0.associatedTicketKeys.contains { $0.lowercased() == lowercasedSearchTerm }
				|| ($0.releaseNotes ?? "").contains(lowercasedSearchTerm)
		}
	}
}
