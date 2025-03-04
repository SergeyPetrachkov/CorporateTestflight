import SwiftUI
import CorporateTestflightDomain

struct JiraViewerView: View {
	@StateObject private var store: JiraViewerStore

	init(store: JiraViewerStore) {
		self._store = .init(wrappedValue: store)
	}

	var body: some View {
		List {
			Section {
				Text(store.state.ticket.title)
					.font(.headline)
				Text(store.state.ticket.key)
					.font(.subheadline)
					.foregroundColor(.secondary)
				Text(store.state.ticket.description)
					.font(.body)
			}

			if store.state.ticket.attachments?.isEmpty == false {
//				Section("Attachments") {
//					if store.state.isLoading {
//						ProgressView()
//					} else {
//						ScrollView(.horizontal) {
//							HStack {
//								ForEach(store.state.attachments, id: \.self) { image in
//									image
//										.resizable()
//										.aspectRatio(contentMode: .fit)
//										.frame(height: 200)
//								}
//							}
//						}
//					}
//				}
			}
		}
		.navigationTitle("Ticket Details")
		.refreshable {
			await store.send(.refresh)
		}
		.task {
			await store.send(.loadAttachments)
		}
	}
}
