import SwiftUI
import CorporateTestflightDomain

struct VersionsListContainer: View {

	@StateObject private var store: VersionsListStore

	init(store: VersionsListStore) {
		self._store = StateObject(wrappedValue: store)
	}

	var body: some View {
		contentView
			.task {
				await store.send(.start)
			}
	}

	@ViewBuilder
	private var contentView: some View {
		switch store.state {
		case .loading:
			ProgressView()
		case .loaded(let content):
			VersionsList(state: content.versions) { tappedItem in
				Task {
					await store.send(.tapItem(tappedItem))
				}
			}
			.refreshable {
				await store.send(.refresh(fromScratch: false))
			}
			.navigationTitle(content.projectTitle)
		case .failed(let error):
			ContentUnavailableView {
				Label("An error has occured", systemImage: "exclamationmark.triangle")
			} description: {
				Text("Error details: \(error).\nTry again.")
			} actions: {
				Button("Reload") {
					Task {
						await store.send(.refresh(fromScratch: true))
					}
				}
				.buttonBorderShape(.roundedRectangle)
				.buttonStyle(.bordered)
			}
		case .initial:
			skeleton
		}
	}

	private var skeleton: some View {
		VersionsList(state: [
			.init(
				id: UUID(),
				title: "Here's the title",
				subtitle: "And here's the long subtitle"
			),
			.init(
				id: UUID(),
				title: "Here's the title",
				subtitle: "And here's the long subtitle"
			)
		]
		) { _ in }
			.redacted(reason: .placeholder)
			.disabled(true)
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
				.font(.title3)
			Text(state.subtitle)
				.font(.body)
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
