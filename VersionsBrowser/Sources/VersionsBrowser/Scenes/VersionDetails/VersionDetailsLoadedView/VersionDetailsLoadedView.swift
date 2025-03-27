import SwiftUI

struct VersionDetailsLoadedView: View {

	let state: State
	let onTicketTapped: (TicketView.State) -> Void

	init(state: State, onTicketTapped: @escaping (TicketView.State) -> Void = { _ in }) {
		self.state = state
		self.onTicketTapped = onTicketTapped
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			VersionDetailsHeaderView(state: state.headerState)

			VStack(alignment: .leading, spacing: 12) {
				Text("Associated tickets:")
					.font(.title2)
				Divider()
				LazyVGrid(
					columns: [GridItem(.adaptive(minimum: 80, maximum: 300))],
					alignment: .leading,
					spacing: 8
				) {
					GridRow(alignment: .top) {
						ForEach(state.ticketsModels) { ticket in
							TicketView(state: ticket)
								.fixedSize(horizontal: true, vertical: true)
								.onTapGesture {
									onTicketTapped(ticket)
								}
						}
					}
				}
			}
			.padding(4)
			.background(Color(red: 245 / 255.0, green: 245 / 255.0, blue: 247 / 255.0))
			.clipShape(RoundedRectangle(cornerSize: .init(width: 8, height: 8), style: .continuous))
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
					associatedTicketKeys: ["Jira-1"]
				),
				tickets: [
					.init(
						id: UUID(),
						key: "Jira-1",
						title: "title",
						description: "descr"
					),
					.init(
						id: UUID(),
						key: "Jira-2",
						title: "title",
						description: "descr"
					),
					.init(
						id: UUID(),
						key: "Jira-3",
						title: "title",
						description: "descr"
					),
					.init(
						id: UUID(),
						key: "Jira-4",
						title: "title",
						description: "descr"
					),
					.init(
						id: UUID(),
						key: "Jira-5",
						title: "title",
						description: "descr"
					),
					.init(
						id: UUID(),
						key: "Jira-6",
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
