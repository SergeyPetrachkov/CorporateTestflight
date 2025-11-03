import SwiftUI

struct VersionDetailsLoadedView: View {

	let state: State
	let onTicketTapped: (TicketViewState) -> Void

	init(state: State, onTicketTapped: @escaping (TicketViewState) -> Void = { _ in }) {
		self.state = state
		self.onTicketTapped = onTicketTapped
	}

	var body: some View {
		List {
			Section {
				VersionDetailsHeaderView(state: state.headerState)
			}
			Section("Associated tickets:") {
				ForEach(state.ticketsModels, id: \.id) { ticket in
					HStack(alignment: .top) {
						Text(ticket.key)
							.fontWeight(.bold)
							.monospaced()
						Text(ticket.title)
					}
					.onTapGesture {
						onTicketTapped(ticket)
					}
				}
			}
		}
	}
}

import CorporateTestflightDomain
#Preview {
	VersionDetailsLoadedView(
		state:
			VersionDetailsLoadedView
			.State(
				version: Version(
					id: UUID(),
					buildNumber: 1,
					releaseNotes: "Something something",
					associatedTicketKeys: ["Jira-1"]
				),
				tickets: [
					.init(
						id: UUID(),
						key: "JIRA-1",
						title: "title",
						description: "descr"
					),
					.init(
						id: UUID(),
						key: "JIRA-22",
						title: "title",
						description: "descr"
					),
					.init(
						id: UUID(),
						key: "JIRA-3",
						title: "title",
						description: "descr"
					),
					.init(
						id: UUID(),
						key: "JIRA-4",
						title: "title",
						description: "descr"
					),
					.init(
						id: UUID(),
						key: "JIRA-5",
						title: "title",
						description: "descr"
					),
					.init(
						id: UUID(),
						key: "JIRA-655",
						title: "title",
						description: "descr"
					)
				]
			),
		onTicketTapped: {
			_ in
		}
	)
}

