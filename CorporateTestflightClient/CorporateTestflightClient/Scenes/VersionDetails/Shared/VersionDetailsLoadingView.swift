import SwiftUI

struct VersionDetailsLoadingView: View {

    let viewModel: VersionDetailsViewModel.State.VersionPreviewViewModel

    var body: some View {
        VStack(alignment: .leading) {
            VersionDetailsHeaderView(viewModel: viewModel.headerViewModel)
            if viewModel.ticketPlaceholdersCount > 0 {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
    }
}
