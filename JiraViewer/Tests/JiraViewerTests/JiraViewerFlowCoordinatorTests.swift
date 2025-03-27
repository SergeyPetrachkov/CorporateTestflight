import Testing
import SimpleDI
import UIKit
import CorporateTestflightDomain
import MockFunc
import JiraViewerInterface
import Foundation
import TestflightFoundation
import ImageLoader
import TestflightNetworking
import TestflightNetworkingMock
import ImageLoaderMock
@testable import JiraViewer

@MainActor
struct JiraViewerFlowCoordinatorTests {

	@MainActor
	struct Environment {
		let container = Container()
		let ticket = Ticket(id: UUID.zero, key: "Key", title: "Title", description: "Descr", attachments: [])
		let parentViewController = ViewControllerSpy()

		func makeSUT() -> JiraViewerFlowCoordinator {
			parentViewController.presentMock.returns()
			container.register(TestflightAPIProviding.self) { _, _ in
				TestflightAPIProvidingMock()
			}
			container.register(ImageLoader.self) { _, _ in
				ImageLoaderMock()
			}
			container.register(TicketsRepository.self) { _, _ in
				MockTicketsRepository()
			}

			let input = JiraViewerFlowInput(
				ticket: ticket,
				parentViewController: parentViewController,
				resolver: container
			)
			return JiraViewerFlowCoordinator(input: input)
		}
	}

	@Test
	func startPreparesEnvironmentAndPresentsJiraView() async throws {
		let env = Environment()

		let sut = env.makeSUT()

		sut.start()
		try #require(env.parentViewController.presentMock.calledOnce)
	}
}
