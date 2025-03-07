import SwiftUI

struct VersionListRow: View {

	let state: VersionList.RowState

	var body: some View {
		VStack(alignment: .leading) {
			Text(state.title)
				.font(.title3)
			Text(state.subtitle)
				.font(.body)
		}
	}
}
