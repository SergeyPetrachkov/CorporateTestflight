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

		print("state >> '\(state)'")
	}
}
