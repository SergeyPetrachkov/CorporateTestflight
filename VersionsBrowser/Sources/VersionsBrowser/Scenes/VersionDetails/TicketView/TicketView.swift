import SwiftUI

struct TicketView: View {

	let state: State

	var body: some View {
		Text(state.key)
			.foregroundColor(.white)
			.fontWeight(.bold)
			.monospaced()
			.padding(.vertical, 8)
			.padding(.horizontal, 16)
			.background(Color.blue)
			.background(in: .capsule)
			.fixedSize()
	}
}

#Preview {
	TicketView(state: .init(ticket: .init(id: UUID(), key: "Jira-1", title: "title", description: "descr")))
}
