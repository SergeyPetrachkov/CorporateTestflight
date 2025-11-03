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
			SkeletonView()
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					loadingToolbarContent
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
				currentSearchTask?.cancel()
				currentSearchTask = Task {
					await store.send(.search)
				}
			}
			.onChange(of: store.state.seachTerm) {
				// here: we hold a reference to a task, we cancel the existing one and we also debounce via Task sleep
				currentSearchTask?.cancel()
				currentSearchTask = Task {
					await store.send(.debouncedSearch)
				}
			}
			.refreshable {
				await store.send(.refresh(fromScratch: false))
			}
			.navigationTitle(content.projectTitle)
			.toolbar {
				toolbarContent
			}
		case .failed(let error):
			ContentUnavailableView {
				Label("An error has occured", systemImage: "exclamationmark.triangle")
			} description: {
				Text("Error details: \(error.localizedDescription).\nTry again.")
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
				toolbarContent
			}
		}
	}

	private var loadingToolbarContent: some ToolbarContent {
		ToolbarItem(placement: .principal) {
			HStack {
				ProgressView()
				Text("Loading").font(.headline)
			}
		}
	}

	private var toolbarContent: some ToolbarContent {
		ToolbarItem(placement: .primaryAction) {
			Button("QR") {
				Task {
					await store.send(.tapQR)
				}
			}
		}
	}
}
