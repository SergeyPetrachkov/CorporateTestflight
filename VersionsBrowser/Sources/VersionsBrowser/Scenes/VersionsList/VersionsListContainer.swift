import SwiftUI
import CorporateTestflightDomain
import TestflightUIKit

struct VersionsListContainer: View {

	@ObservedObject private var store: VersionsListStore
	@State private var currentSearchTask: Task<Void, any Error>?

	init(store: VersionsListStore) {
		self.store = store
	}

	var body: some View {
		contentView
	}

	@ViewBuilder
	private var contentView: some View {
		switch store.state.contentState {
		case .loading:
			skeleton
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .principal) {
						HStack {
							ProgressView()
							Text("Loading").font(.headline)
						}
					}
				}
				.task {
					await store.send(.start)
				}
		case .loaded(let content):
			VersionsList(state: content.versions) { tappedItem in
				Task {
					await store.send(.tapItem(tappedItem))
				}
			}
			.searchable(text: $store.state.seachTerm, prompt: "Jira keys or release notes")
			.onSubmit(of: .search) {
				Task {
					await store.send(.search)
				}
			}
			.onChange(of: store.state.seachTerm) {
				// here: we hold a reference to a task, we cancel the existing one and we also debounce via Task sleep
				currentSearchTask?.cancel()
				currentSearchTask = Task {
					try await Task.sleep(for: .milliseconds(300))
					try Task.checkCancellation()
					await store.send(.debouncedSearch)
				}
			}
			.refreshable {
				await store.send(.refresh(fromScratch: false))
			}
			.navigationTitle(content.projectTitle)
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button("QR") {
						Task {
							await store.send(.tapQR)
						}
					}
				}
			}
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
			.navigationTitle("Oops...")
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button("QR") {
						Task {
							await store.send(.tapQR)
						}
					}
				}
			}
		}
	}

	private var skeleton: some View {
		SkeletonView()
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
