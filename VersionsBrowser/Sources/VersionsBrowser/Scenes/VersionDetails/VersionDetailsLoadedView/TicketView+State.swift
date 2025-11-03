import CorporateTestflightDomain

struct TicketViewState: Equatable, Identifiable {
    let id: Ticket.ID
    let key: String
    let title: String
    let body: String

    init(ticket: Ticket) {
        self.id = ticket.id
        self.key = ticket.key
        self.title = ticket.title
        self.body = ticket.description
    }
}
