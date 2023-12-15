import SwiftUI

struct VersionDetailsLoadedView: View {

    let viewModel: VersionDetailsViewModel.State.LoadedVersionDetailsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            VersionDetailsHeaderView(viewModel: viewModel.headerViewModel)

            Text("Associated tickets:")
                .font(.title2)
            ForEach(viewModel.ticketsModels) { ticket in
                TicketView(viewModel: ticket)
            }
        }
    }
}
