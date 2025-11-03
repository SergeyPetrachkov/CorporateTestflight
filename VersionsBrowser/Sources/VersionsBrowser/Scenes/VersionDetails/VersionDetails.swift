import Foundation
import CorporateTestflightDomain

enum VersionDetails {
	struct Environment {
		let version: Version
		let fetchTicketsUsecase: FetchTicketsUseCaseProtocol

		let onTickedTapped: (Ticket) -> Void
	}

	enum Action: CustomDebugStringConvertible {
		case start
		case refresh
		case tap(TicketViewState)

		var debugDescription: String {
			switch self {
			case .start:
				"start"
			case .refresh:
				"refresh"
			case .tap(let item):
				"tap: \(item.key)"
			}
		}
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
