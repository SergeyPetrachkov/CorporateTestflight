import SwiftUI

struct TicketView: View {
    
    let viewModel: VersionDetailsViewModel.State.LoadedVersionDetailsViewModel.TicketViewModel

    var body: some View {
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
