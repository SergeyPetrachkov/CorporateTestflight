import SwiftUI
import TestflightUIKit

struct VersionDetailsLoadingView: View {

	let state: State

	var body: some View {
		VStack(alignment: .leading) {
			VersionDetailsHeaderView(state: state.headerState)
			if state.ticketPlaceholdersCount > 0 {
				SkeletonView()
					.contentMargins(0)
			}
		}
	}
}

#Preview {
	VersionDetailsLoadingView(
		state: .init(
			version: .init(
				id: UUID(),
				buildNumber: 1,
				associatedTicketKeys: ["Key 1", "Key 2"]
			)
		)
	)
}
