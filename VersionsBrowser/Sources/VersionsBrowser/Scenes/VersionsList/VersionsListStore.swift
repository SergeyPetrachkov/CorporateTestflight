import Combine
import CorporateTestflightDomain
import UniFlow

// Plan: 7 Store implementation
// Implement Store. Start from the empty store.
// Implement loadData with the flag (fromScratch)
// Introduce Nonisolated async as an optimisation (pure function)
// Implement filtering as a pure function
// Cancellation Checks

final class VersionsListStore: ObservableObject, Store {

	typealias State = VersionList.State
	typealias Environment = VersionList.Environment
	typealias Action = VersionList.Action

	let environment: VersionList.Environment

	@Published var state: State

	init(initialState: State, environment: Environment) {
		self.state = initialState
		self.environment = environment
	}

	func send(_ action: VersionList.Action) async {
		print("'action: \(action)' >> 'state: \(state)'")

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
		print("state >> '\(state)'")
	}
}
