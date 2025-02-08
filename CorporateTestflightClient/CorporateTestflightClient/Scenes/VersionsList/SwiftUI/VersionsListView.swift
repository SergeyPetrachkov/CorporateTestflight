import SwiftUI
import CorporateTestflightDomain

struct VersionsListContainer: View {

	let store: VersionsListStore

	var body: some View {
		VersionsList(state: []) { tappedItem in
			Task {
				await store.send(.tapItem(tappedItem))
			}
		}
		.task {
			await store.send(.start)
		}
	}
}

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

struct VersionListRow: View {

	let state: VersionList.RowState

	var body: some View {
		VStack(alignment: .leading) {
			Text(state.title)
				.font(.title2)
			Text(state.subtitle)
				.font(.caption)
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

// Do we even need this one if we have a list preview? Maybe yes, maybe no.
#Preview("Behavior-less Row") {
	VersionListRow(state: .init(id: UUID(), title: "Title", subtitle: "Subtitle"))
	VersionListRow(state: .init(id: UUID(), title: "Here's the title", subtitle: "And here's the long subtitle"))
}
