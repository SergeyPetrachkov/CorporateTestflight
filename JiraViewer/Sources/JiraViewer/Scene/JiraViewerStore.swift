import Combine
import UniFlow
import CorporateTestflightDomain

final class JiraViewerStore: Store, ObservableObject {
	typealias State = JiraViewer.State
	typealias Environment = JiraViewer.Environment
	typealias Action = JiraViewer.Action

	let environment: Environment
	@Published var state: State

	init(initialState: State, environment: Environment) {
		self.environment = environment
		self.state = initialState
	}

	deinit {
		print("❌ deinit \(self)")
	}

	func send(_ action: Action) async {
		print("'action: \(action)' >> 'state: \(state)'")
		switch action {
		case .start, .refresh:
			if let attachmentsToLoad = environment.ticket.attachments {
				do {
					let attachments = try await environment.attachmentLoader.execute(attachments: attachmentsToLoad)
					state.footer = .loaded(
						JiraViewer.TicketAttachmentsState(
							images: attachments.map { JiraViewer.LoadedImage(resourceURL: $0.0, image: $0.1) }
						)
					)
				} catch {
					state.footer = .failed(.init(description: error.localizedDescription))
				}
			} else {
				state.footer = .loaded(
					JiraViewer.TicketAttachmentsState(
						images: []
					)
				)
			}
		}
		print("state >> '\(state)'")
	}
}
