import CorporateTestflightDomain

extension VersionDetailsLoadedView {
	struct State: Equatable {

		let headerState: VersionDetailsHeaderView.State
		let ticketsModels: [TicketViewState]

		init(version: Version, tickets: [Ticket]) {
			self.headerState = .init(version: version)
			self.ticketsModels = tickets.map(TicketViewState.init)
		}
	}
}
