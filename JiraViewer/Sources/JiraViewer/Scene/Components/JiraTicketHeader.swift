import SwiftUI

struct JiraTicketHeader: View {

	let state: JiraViewer.TicketHeaderState

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text("#\(state.key)-\(state.title)")
				.font(.headline)
			if let description = state.description {
				Text(description)
					.font(.body)
			}
		}
	}
}

#Preview {
	JiraTicketHeader(
		state: JiraViewer.TicketHeaderState(
			title: "Test ticket",
			key: "TEST-123",
			description: "This is a test ticket. With a loooong looong looong description.\nand then some multiline text"
		)
	)
}
