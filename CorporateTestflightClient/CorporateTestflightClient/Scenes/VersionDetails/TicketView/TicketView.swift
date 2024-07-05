import SwiftUI

struct TicketView: View {

    let state: State

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(state.key)
                    .fontWeight(.bold)
                Text(state.title)
                    .fontWeight(.medium)
            }
            .lineLimit(2)
            Text(state.body)
                .font(.caption)
                .lineLimit(3)
        }
    }
}
