import SwiftUI

struct VersionsList: View {

	let state: [VersionList.RowState]
	let onItemTap: (VersionList.RowState) -> Void

	var body: some View {
		if state.isEmpty {
			ContentUnavailableView("No versions found", systemImage: "exclamationmark.triangle")
		} else {
			List(state) { item in
				VersionListRow(state: item)
					.id(item.id)
					.onTapGesture {
						onItemTap(item)
					}
			}
		}
	}
}
