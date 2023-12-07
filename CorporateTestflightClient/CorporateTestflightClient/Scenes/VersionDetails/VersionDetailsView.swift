import SwiftUI

struct VersionDetailsView: View {

    @ObservedObject var viewModel: VersionDetailsViewModel

    var body: some View {
        contentView(for: viewModel.state)
    }

    @ViewBuilder
    private func contentView(for state: VersionDetailsViewModel.State) -> some View {
        switch viewModel.state {
        case .loading(let version):
            Text("\(version.buildNumber)")
        case .loaded(let version, let tickets):
            Text("\(version.buildNumber)")
        case .failed(let error):
            VStack {
                Text("Something went wrong")
                Text(error.localizedDescription)
                Button("Retry", action: {})
            }
        }
    }
}
