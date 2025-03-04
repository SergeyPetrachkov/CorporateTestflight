import Combine
import UniFlow
import CorporateTestflightDomain
import ImageLoader

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

	func send(_ action: Action) async {
//		switch action {
//		case .loadAttachments, .refresh:
//			guard let attachmentUrls = environment.ticket.attachments else { return }
//
//			state.isLoading = true
//			do {
//				state.attachments = try await withThrowingTaskGroup(of: LoadableImage.self) { group in
//					for url in attachmentUrls {
//						group.addTask {
//							try await self.environment.attachmentLoader.loadAttachment(url: url)
//						}
//					}
//
//					var attachments: [LoadableImage] = []
//					for try await attachment in group {
//						attachments.append(attachment)
//					}
//					return attachments
//				}
//			} catch {
//				// Handle error
//				state.attachments = []
//			}
//			state.isLoading = false
//		}
	}
}
