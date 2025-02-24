import Foundation
import CorporateTestflightDomain

enum VersionDetails {
	struct Environment {
		let version: Version
		let fetchTicketsUsecase: FetchTicketsUseCaseProtocol
	}

	enum Action {
		case start
		case refresh
	}

	enum State: Equatable, CustomDebugStringConvertible {

		// MARK: - Nested VMs

		struct ErrorViewModel: Equatable {
			let message: String
		}

		// MARK: - Cases

		case initial
		case loading(VersionDetailsLoadingView.State)
		case loaded(VersionDetailsLoadedView.State)
		case failed(ErrorViewModel)

		var debugDescription: String {
			switch self {
			case .initial:
				"initial"
			case .loading:
				"loading"
			case .loaded:
				"loaded"
			case .failed(let errorViewModel):
				"failed: \(errorViewModel.message)"
			}
		}
	}
}
