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
                    Text(error.localizedDescription)
                    Button("Retry", action: viewModel.start)
                }
            }
        }
        .refreshable {
            viewModel.start()
        }
    }

    @ViewBuilder
    private func loadingView(versionPreview: VersionDetailsViewModel.State.VersionPreviewViewModel) -> some View {
        VStack(alignment: .leading) {
            headerView(viewModel: versionPreview.headerViewModel)
            if versionPreview.ticketPlaceholdersCount > 0 {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
//        .task {
//            await viewModel.start()
//        }
    }

    @ViewBuilder
    private func loadedView(detailsModel: VersionDetailsViewModel.State.LoadedVersionDetailsViewModel) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            headerView(viewModel: detailsModel.headerViewModel)

            Text("Associated tickets:")
                .font(.title2)
            ForEach(detailsModel.ticketsModels) { ticket in
                ticketView(viewModel: ticket)
            }
        }
    }

    @ViewBuilder
    private func headerView(viewModel: VersionDetailsViewModel.State.VersionHeaderViewModel) -> some View {
        Text(viewModel.title)
            .font(.title)
        if let body = viewModel.body {
            Divider()
            Text("Release notes:")
                .font(.title2)
            Text(body)
                .font(.body)
                .padding(.top, 4)
        }
        Divider()
    }

    @ViewBuilder
    private func ticketView(viewModel: VersionDetailsViewModel.State.LoadedVersionDetailsViewModel.TicketViewModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(viewModel.key)
                    .fontWeight(.bold)
                Text(viewModel.title)
                    .fontWeight(.medium)
            }
            .lineLimit(1)
            Text(viewModel.body)
                .font(.caption)
                .lineLimit(3)

            Divider()
        }
    }
}
