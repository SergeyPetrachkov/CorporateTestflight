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
				ForEach(state.ticketsModels) { ticket in
					TicketView(state: ticket)
						.onTapGesture {
							onTicketTapped(ticket)
						}
				}
			}
			.padding(4)
			.background(Color(red: 245 / 255.0, green: 245 / 255.0, blue: 247 / 255.0))
			.clipShape(RoundedRectangle(cornerSize: .init(width: 8, height: 8), style: .continuous))
		}
	}
}

