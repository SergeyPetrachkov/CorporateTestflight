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
			attachmentLoader: input.resolver.resolve(ImageLoader.self)!,
			ticket: input.ticket
		)
		let state = JiraViewer.State(ticket: input.ticket)
		let store = JiraViewerStore(initialState: state, environment: env)
		let view = JiraViewerView(store: store)
		let hostingVC = UIHostingController(rootView: view)
		input.parentViewController.present(hostingVC, animated: true)
	}
}
