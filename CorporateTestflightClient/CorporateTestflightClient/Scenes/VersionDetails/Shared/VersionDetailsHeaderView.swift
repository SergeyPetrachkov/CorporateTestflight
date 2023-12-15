import SwiftUI

struct VersionDetailsHeaderView: View {

    let viewModel: VersionDetailsViewModel.State.VersionHeaderViewModel

    var body: some View {
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
}
