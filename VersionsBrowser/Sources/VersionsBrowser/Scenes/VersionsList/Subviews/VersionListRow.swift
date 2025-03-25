import SwiftUI

struct VersionListRow: View {

	let state: VersionList.RowState

	var body: some View {
		VStack(alignment: .leading) {
			Text(state.title)
				.font(.title3)
			Text(state.subtitle)
				.font(.body)
		}
	}
}

// Do we even need this one if we have a list preview? Maybe yes, maybe no.
#Preview("Behavior-less Row") {
	VersionListRow(state: .init(id: UUID(), title: "Title", subtitle: "Subtitle"))
	VersionListRow(state: .init(id: UUID(), title: "Here's the title", subtitle: "And here's the long subtitle"))
}
