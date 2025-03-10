import CorporateTestflightDomain
import Foundation
import ImageLoader

enum JiraViewer {
	enum Action {
		case start
		case refresh
	}

	struct Environment {
		let attachmentLoader: LoadAttachmentsUsecase
		let ticketsRepository: TicketsRepository
		var ticket: Ticket
	}

	struct TicketHeaderState {
		let title: String
		let key: String
		let description: String?
	}

	struct LoadedImage: Identifiable {
		let resourceURL: URL
		let image: LoadableImage

		var id: URL {
			resourceURL
		}
	}

	struct TicketAttachmentsState {
		let images: [LoadedImage]
	}

	struct ErrorState {
		let description: String
	}

	struct LoadedState {
		let header: TicketHeaderState
		let footer: TicketAttachmentsState
	}

	struct State: CustomDebugStringConvertible {

		enum LoadableFooterState {
			case loading
			case loaded(TicketAttachmentsState)
			case failed(ErrorState)
		}
		var header: TicketHeaderState
		var footer: LoadableFooterState

		var debugDescription: String {
			switch footer {
			case .loading:
				"\(header.key):loading"
			case .loaded:
				"\(header.key):loaded"
			case .failed:
				"\(header.key):failed"
			}
		}
	}
}

extension JiraViewer.State {
	init(ticket: Ticket) {
		self.header = .init(title: ticket.title, key: ticket.key, description: ticket.description)
		self.footer = .loading
	}
}
