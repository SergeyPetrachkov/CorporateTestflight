import Combine
import CorporateTestflightDomain
import UniFlow

// Plan: 7 Store implementation
// Implement Store. Start from the empty store.
// Introduce Nonisolated async as an optimisation
// Cancellation Checks

final class VersionsListStore: ObservableObject, Store {

	typealias State = VersionList.State
	typealias Environment = VersionList.Environment
	typealias Action = VersionList.Action

	let environment: VersionList.Environment

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
		case .search:
			await searchData()
		case .debouncedSearch:
			do {
				try await Task.sleep(for: .milliseconds(environment.debounceMilliseconds))
				try Task.checkCancellation()
				await searchData()
			} catch {
				print(error)
			}
		}
		print("state >> '\(state)'")
	}

	private func loadData(enterLoadingState: Bool) async {
		do {
			if enterLoadingState {
				state.contentState = .loading
			}
			let (project, builds) = try await environment.usecase.execute(projectId: environment.project)

			try Task.checkCancellation()

			let mappedContent = await map(project: project, versions: builds)

			try Task.checkCancellation()

			versions = builds
			self.project = project
			state.contentState = .loaded(mappedContent)
		} catch is CancellationError {
			print("Store cancelled")
		} catch {
			state.contentState = .failed(.init(localizedDescription: error.localizedDescription))
		}
	}

	private func searchData() async {
		guard let project else {
			state.contentState = .failed(.init(localizedDescription: "No project is loaded. Try refreshing."))
			return
		}
		let filteredVersions = await filterVersions(searchTerm: state.seachTerm, versions: versions)
		let mappedContent = await map(project: project, versions: filteredVersions)
		state.contentState = .loaded(mappedContent)
	}

	nonisolated private func map(project: Project, versions: [Version]) async -> VersionList.State.Content {
		let rows = environment.mapper.map(versions: versions)
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
