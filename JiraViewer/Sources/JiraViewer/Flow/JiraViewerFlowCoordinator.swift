import SwiftUI
import CorporateTestflightDomain
import JiraViewerInterface
import ImageLoader

final class JiraViewerFlowCoordinator: JiraViewerFlowCoordinating {

	typealias Input = JiraViewerFlowInput

	private let input: Input

	init(input: Input) {
		self.input = input
	}

	func start() {
		let env = JiraViewer.Environment(
			attachmentLoader: LoadAttachmentsUsecaseImpl(imageLoader: input.resolver.resolve(ImageLoader.self)!),
			ticket: input.ticket
		)
		let store = JiraViewerStore(initialState: .init(ticket: input.ticket), environment: env)
		let view = JiraViewerContainer(store: store)
		let hostingVC = UIHostingController(rootView: view)
		input.parentViewController.present(hostingVC, animated: true)
	}
}
