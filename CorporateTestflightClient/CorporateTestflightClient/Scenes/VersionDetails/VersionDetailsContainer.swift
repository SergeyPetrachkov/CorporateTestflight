import SwiftUI
import TestflightUIKit

struct VersionDetailsContainer: View {

	@ObservedObject var store: VersionDetailsStore

	var body: some View {
		contentView(for: store.state)
			.padding(.horizontal, 16)
	}

	@ViewBuilder
	private func contentView(for state: VersionDetailsStore.State) -> some View {

		switch store.state {
		case .loading(let state):
			loadingView(versionPreview: state)
		case .loaded(let state):
			ScrollView {
				loadedView(detailsModel: state)
			}
			.refreshable {
				await store.send(.refresh)
			}
		case .failed(let error):
			ContentUnavailableView(
				label: {
					VStack {
						Image(systemName: "cable.connector.horizontal")
						Text("Something went wrong")
							.font(.headline)
						Text(error.message)
							.font(.subheadline)
					}
				},
				actions: {
					Button("Retry") {
						Task {
							await store.send(.refresh)
						}
					}
				}
			)
		case .initial:
			skeleton
		}
	}

	@ViewBuilder
	private func loadingView(versionPreview: VersionDetailsLoadingView.State) -> some View {
		VersionDetailsLoadingView(state: versionPreview)
			.task {
				await store.send(.start)
			}
	}

	@ViewBuilder
	private func loadedView(detailsModel: VersionDetailsLoadedView.State) -> some View {
		VersionDetailsLoadedView(state: detailsModel)
	}

	@ViewBuilder
	private var skeleton: some View {
		SkeletonView()
	}
}
