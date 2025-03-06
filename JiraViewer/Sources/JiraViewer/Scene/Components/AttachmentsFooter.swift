import SwiftUI

struct AttachmentsFooter: View {
	let state: JiraViewer.TicketAttachmentsState

	var body: some View {
		if state.images.isEmpty {
			Text("No attachments")
		} else {
			GridRow(alignment: .top) {
				ForEach(state.images) { imageDescriptor in
					LoadedImageView(state: imageDescriptor)
				}
			}
		}
	}
}

#Preview {
	AttachmentsFooter(
		state: JiraViewer.TicketAttachmentsState(
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
				JiraViewer.LoadedImage(
					resourceURL: URL(
						string: "https://example.image2.jpg"
					)!,
					image: UIImage(
						systemName: "cross"
					)!
				)
			]
		)
	)
}
