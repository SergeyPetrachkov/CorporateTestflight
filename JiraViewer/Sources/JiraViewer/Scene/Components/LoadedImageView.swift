import SwiftUI

struct LoadedImageView: View {
	let state: JiraViewer.LoadedImage

	var body: some View {
		Image(uiImage: state.image)
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(height: 50)
			.id(state.id)
	}
}

#Preview {
	LoadedImageView(
		state: JiraViewer.LoadedImage(
			resourceURL: URL(
				string: "https://example.image.jpg"
			)!,
			image: UIImage(
				systemName: "circle"
			)!
		)
	)
}
