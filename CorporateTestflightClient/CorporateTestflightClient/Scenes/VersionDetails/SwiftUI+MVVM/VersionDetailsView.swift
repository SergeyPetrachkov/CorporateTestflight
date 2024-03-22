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
            case .loading(let viewModel):
                loadingView(versionPreview: viewModel)
            case .loaded(let viewModel):
                loadedView(detailsModel: viewModel)
            case .failed(let error):
                VStack {
                    Text("Something went wrong")
                    Text(error.message)
                    Button("Retry") {
                        viewModel.start()
                    }
                }
            }
        }
        .refreshable {
            viewModel.start()
        }
    }

    @ViewBuilder
    private func loadingView(versionPreview: VersionDetailsViewModel.State.VersionPreviewViewModel) -> some View {
        VersionDetailsLoadingView(viewModel: versionPreview)
            .onAppear {
                viewModel.start()
            }
            .onDisappear {
                viewModel.stop()
            }
    }

    @ViewBuilder
    private func loadedView(detailsModel: VersionDetailsViewModel.State.LoadedVersionDetailsViewModel) -> some View {
        VersionDetailsLoadedView(viewModel: detailsModel)
    }
}
