import SwiftUI

struct VersionsList: View {

	let state: [VersionList.RowState]
	let onItemTap: (VersionList.RowState) -> Void

	var body: some View {
		if state.isEmpty {
			ContentUnavailableView("No versions found", systemImage: "exclamationmark.triangle")
		} else {
			List(state) { item in
				VersionListRow(state: item)
					.id(item.id)
					.onTapGesture {
						onItemTap(item)
					}
			}
		}
	}
}

#Preview("Behavior-less filled List") {
	VersionsList(
		state: [
			.init(
				id: UUID(),
				title: "Title",
				subtitle: "Subtitle"
			),
			.init(
				id: UUID(),
				title: "Here's the title",
				subtitle: "And here's the long subtitle"
			),
			.init(
				id: UUID(),
				title: "Here's the title",
				subtitle: "And here's the long long long long long long longest subtitle in the world"
			),
		],
		onItemTap: { _ in }
	)
}

#Preview("Behavior-less empty List") {
	VersionsList(
		state: [],
		onItemTap: { _ in }
	)
}
