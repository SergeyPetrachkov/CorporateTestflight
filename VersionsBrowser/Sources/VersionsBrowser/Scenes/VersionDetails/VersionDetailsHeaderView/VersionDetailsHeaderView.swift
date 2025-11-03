import SwiftUI

struct VersionDetailsHeaderView: View {

	let state: State

	var body: some View {
		VStack(alignment: .leading) {
			Text(state.title)
				.font(.title)
			if let body = state.body {
				Divider()
				Text("Release notes:")
					.font(.title2)
				Text(body)
					.font(.body)
					.padding(.top, 4)
			}
		}
	}
}

import CorporateTestflightDomain
#Preview {
	VersionDetailsHeaderView(
		state: .init(
			version: Version(
				id: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
				buildNumber: 1,
				releaseNotes: "Some release notes added here for the sake of testing",
				associatedTicketKeys: ["JIRA-1", "JIRA-2"]
			)
		)
	)
	.padding(8)
}
