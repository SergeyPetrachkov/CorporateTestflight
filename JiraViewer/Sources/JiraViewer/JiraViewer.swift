import CorporateTestflightDomain
import Foundation
import ImageLoader

enum JiraViewer {
	enum Action {
		case loadAttachments
		case refresh
	}

	struct Environment {
		let attachmentLoader: ImageLoader
		let ticket: Ticket

		init(attachmentLoader: ImageLoader, ticket: Ticket) {
			self.attachmentLoader = attachmentLoader
			self.ticket = ticket
		}
	}

	struct State {
		let ticket: Ticket
		var attachments: [LoadableImage]
		var isLoading: Bool

		init(ticket: Ticket, attachments: [LoadableImage] = [], isLoading: Bool = false) {
			self.ticket = ticket
			self.attachments = attachments
			self.isLoading = isLoading
		}
	}
}
