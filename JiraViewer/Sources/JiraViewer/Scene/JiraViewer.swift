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

	struct TicketHeaderState: Equatable {
		let title: String
		let key: String
		let description: String?
	}

	struct LoadedImage: Identifiable, Equatable, CustomDebugStringConvertible {
		let resourceURL: URL
		let image: LoadableImage

		var id: URL {
			resourceURL
		}

		var debugDescription: String {
			id.absoluteString
		}
	}

	struct TicketAttachmentsState: Equatable {
		let images: [LoadedImage]
	}

	struct ErrorState: Equatable {
		let description: String
	}

	struct LoadedState {
		let header: TicketHeaderState
		let footer: TicketAttachmentsState
	}

	struct State: CustomDebugStringConvertible, Equatable {

		enum LoadableFooterState: Equatable {
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
			case .loaded(let state):
				"\(header.key):loaded,attachments:\(state.images)"
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
