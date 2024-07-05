import SwiftUI

struct VersionDetailsLoadingView: View {

    let state: State

    var body: some View {
        VStack(alignment: .leading) {
            VersionDetailsHeaderView(state: state.headerState)
            if state.ticketPlaceholdersCount > 0 {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
    }
}
