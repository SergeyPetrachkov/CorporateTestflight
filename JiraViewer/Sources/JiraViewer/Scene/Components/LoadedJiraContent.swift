import SwiftUI

struct LoadedJiraContent: View {

	let state: JiraViewer.LoadedState

	var body: some View {
		Section("Ticket details") {
			JiraTicketHeader(state: state.header)
				.id(state.header.key)
		}
		.id(state.header.key)
		Section("Attachments") {
			Grid {
				AttachmentsFooter(state: state.footer)
			}
		}
	}
}

#Preview {
	List {
		LoadedJiraContent(
			state: JiraViewer.LoadedState(
				header: JiraViewer.TicketHeaderState(title: "A ticket", key: "Jira-1", description: "Some description here"),
				footer: JiraViewer.TicketAttachmentsState(
					images: [
						JiraViewer.LoadedImage(
							resourceURL: URL(
								string: "https://example.image.jpg"
							)!,
							image: UIImage(
								systemName: "circle"
							)!
						),
						JiraViewer.LoadedImage(
							resourceURL: URL(
								string: "https://example.image1.jpg"
							)!,
							image: UIImage(
								systemName: "square"
							)!
						),
					]
				)
			)
		)
	}
}

