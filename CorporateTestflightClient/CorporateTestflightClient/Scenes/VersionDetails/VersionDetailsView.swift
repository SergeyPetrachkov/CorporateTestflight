import SwiftUI

struct VersionDetailsView: View {

    @ObservedObject var viewModel: VersionDetailsViewModel

    var body: some View {
        contentView(for: viewModel.state)
            .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func contentView(for state: VersionDetailsViewModel.State) -> some View {
        ScrollView {
            switch viewModel.state {
            case .loading(let state):
                loadingView(versionPreview: state)
            case .loaded(let state):
                loadedView(detailsModel: state)
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
                            viewModel.send(.onReload)
                        }
                    }
                )
            }
        }
        .refreshable {
            viewModel.send(.onReload)
        }
    }

    @ViewBuilder
    private func loadingView(versionPreview: VersionDetailsLoadingView.State) -> some View {
        VersionDetailsLoadingView(state: versionPreview)
            .onAppear {
                viewModel.send(.onAppear)
            }
            .onDisappear {
                viewModel.send(.onDisappear)
            }
    }

    @ViewBuilder
    private func loadedView(detailsModel: VersionDetailsLoadedView.State) -> some View {
        VersionDetailsLoadedView(state: detailsModel)
    }
}
