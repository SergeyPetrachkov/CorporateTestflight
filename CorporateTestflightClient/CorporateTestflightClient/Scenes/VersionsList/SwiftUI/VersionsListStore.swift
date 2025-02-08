import Combine

@MainActor
final class VersionsListStore: ObservableObject {

	@Published var state: VersionList.State
	let env: VersionList.Environment

	init(state: VersionList.State = .initial(projectID: 1), environment: VersionList.Environment) {
		self.state = state
		self.env = environment
	}

	func send(_ action: VersionList.Action) async {
		switch action {
		case .start:
			guard case let .initial(projectId) = state else {
				return // start can only be triggered once, huh?
			}

			do {
				state = .loading(previousState: state)
				let (project, builds) = try await env.usecase.execute(projectId: projectId)
				state = .loaded(.init(project: project, versions: builds))
			} catch {
				state = .failed(error)
			}
		case .tapItem:
			break
		}
	}
}
