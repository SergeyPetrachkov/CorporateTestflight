import SwiftUI
import CorporateTestflightDomain

struct JiraViewerContainer: View {

	@ObservedObject private var store: JiraViewerStore

	init(store: JiraViewerStore) {
		self.store = store
	}

	var body: some View {
		NavigationView {
			List {
				switch store.state.footer {
				case .loading:
					Section("Ticket details") {
						JiraTicketHeader(state: store.state.header)
							.id(store.state.header.key)
					}
					.id(store.state.header.key)
					Section("Attachments") {
						ProgressView().frame(maxWidth: .infinity)
					}
				case .loaded(let loadedFooter):
					LoadedJiraContent(state: JiraViewer.LoadedState(header: store.state.header, footer: loadedFooter))
				case .failed(let errorState):
					ContentUnavailableView(
						label: {
							VStack {
								Image(systemName: "cable.connector.horizontal")
								Text("Something went wrong")
									.font(.headline)
								Text(errorState.description)
									.font(.subheadline)
							}
						},
						actions: {
							Button("Retry") {
								Task {
									await store.send(.refresh)
								}
							}
						}
					)
				}
			}
			.navigationTitle("Jira")
			.navigationBarTitleDisplayMode(.inline)
			.refreshable {
				await store.send(.refresh)
			}
		}
		.task {
			await store.send(.start)
		}
	}
}
