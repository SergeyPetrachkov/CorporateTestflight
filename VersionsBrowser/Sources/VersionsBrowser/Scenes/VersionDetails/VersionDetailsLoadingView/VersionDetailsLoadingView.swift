import SwiftUI
import TestflightUIKit

struct VersionDetailsLoadingView: View {

	let state: State

	var body: some View {
		List {
			Section {
				VersionDetailsHeaderView(state: state.headerState)
			}
			Section("Associated tickets:") {
				ProgressView().frame(maxWidth: .infinity)
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
