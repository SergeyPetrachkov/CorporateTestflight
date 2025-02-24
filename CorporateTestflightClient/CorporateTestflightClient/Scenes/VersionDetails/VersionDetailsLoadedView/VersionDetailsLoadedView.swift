import SwiftUI

struct VersionDetailsLoadedView: View {

	let state: State

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			VersionDetailsHeaderView(state: state.headerState)

			VStack(alignment: .leading, spacing: 12) {
				Text("Associated tickets:")
					.font(.title2)
				Divider()
				ForEach(state.ticketsModels) { ticket in
					TicketView(state: ticket)
				}
			}
			.padding(4)
			.background(Color(red: 245 / 255.0, green: 245 / 255.0, blue: 247 / 255.0))
			.clipShape(RoundedRectangle(cornerSize: .init(width: 8, height: 8), style: .continuous))
		}
	}
}

