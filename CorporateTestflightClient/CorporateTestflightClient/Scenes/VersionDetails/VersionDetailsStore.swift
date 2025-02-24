import CorporateTestflightDomain
import Foundation
import UniFlow


final class VersionDetailsStore: ObservableObject, Store {

	typealias Environment = VersionDetails.Environment
	typealias Action = VersionDetails.Action
	typealias State = VersionDetails.State
	// MARK: - Injectables
	let environment: Environment

	// MARK: - State
	@Published private(set) var state: State {
		didSet {
			print("state >> '\(state)'")
		}
	}

	// MARK: - Init

	init(initialState: State, environment: Environment) {
		self.environment = environment
		self.state = .loading(VersionDetailsLoadingView.State(version: environment.version))
	}

	deinit {
		print("deinit \(self)")
	}

	// MARK: - Sync interface controlled by us

	func send(_ action: VersionDetails.Action) async {
		print("'action: \(action)' >> 'state: \(state)'")
		switch action {
		case .start, .refresh:
			await fetchData()
		}
	}

	// MARK: - Private logic

	private func fetchData() async {
		do {
			let version = environment.version
			let tickets = try await environment.fetchTicketsUsecase.execute(for: version)
			if !Task.isCancelled {
				state = .loaded(.init(version: version, tickets: tickets))
			} else {
				print("VM is stopped. State won't be published")
			}
		} catch {
			state = .failed(State.ErrorViewModel(message: error.localizedDescription))
		}
	}
}

