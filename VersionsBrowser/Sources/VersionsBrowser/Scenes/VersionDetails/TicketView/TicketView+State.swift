import CorporateTestflightDomain

extension TicketView {
	struct State: Equatable, Identifiable {
		let key: String
		let title: String
		let body: String

		var id: String {
			key
		}

		init(ticket: Ticket) {
			self.key = ticket.key
			self.title = ticket.title
			self.body = ticket.description
		}
	}
}
