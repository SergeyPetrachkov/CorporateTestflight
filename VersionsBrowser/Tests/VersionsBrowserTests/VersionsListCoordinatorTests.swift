import Testing
import XCTest

import VersionsBrowserInterface
import JiraViewerInterface
import SimpleDI
import CorporateTestflightDomain
import MockFunc
import SwiftUI

@testable import VersionsBrowser

// Plan: 10 Coordinator tests

// Create a test for the start function
// How do I test this output thingy? Testing closures.

@MainActor
struct Environment {

	let projectID = 1
	let container = Container()
	let parentController = ViewControllerSpy()
	let mockVersionsRepo = MockVersionsRepository()
	let mockProjectsRepo = MockProjectsRepository()
	let mockTicketRepo = MockTicketsRepository()
	let factory: CachingProxyVersionsBrowserFactory

	init() {
		self.factory = CachingProxyVersionsBrowserFactory(realFactory: VersionsBrowserFactoryImpl(resolver: container))
	}

	func makeSUT() -> VersionsListCoordinator {

		container.register(VersionsRepository.self) { _, _ in
			mockVersionsRepo
		}

		container.register(ProjectsRepository.self) { _, _ in
			mockProjectsRepo
		}

		container.register(TicketsRepository.self) { _, _ in
			mockTicketRepo
		}

		return VersionsListCoordinator(
			input: .init(
				projectId: projectID,
				parentViewController: parentController,
				resolver: container
			),
			factory: factory
		)
	}
}

@Suite("Versions list coordinator tests")
@MainActor
struct VersionsListCoordinatorTests {

	@Test
	func startShouldSetVC() {
		let env = Environment()
		env.parentController.setMock.returns()
		let sut = env.makeSUT()

		sut.start()

		#expect(env.parentController.setMock.input.0.last is UIHostingController<VersionsListContainer>)
		#expect(env.parentController.setMock.input.1)
	}
}

@MainActor
final class TraditionalVersionsListCoordinatorTests: XCTestCase {

	func test_output_ShouldTriggerExternalOutput_WhenQRTapped() async {
		let env = Environment()
		env.parentController.setMock.returns()
		let sut = env.makeSUT()
		let expectation = expectation(description: "output")
		sut.output = { output in
			XCTAssertTrue(output == .qrRequested)
			expectation.fulfill()
		}

		sut.start()

		let store: VersionsListStore = env.factory[dynamicMember: "store"]
		await store.send(.tapQR)
		await fulfillment(of: [expectation], timeout: 0.1)
	}

	func test_OutputShouldTriggerNavigation_WhenVersionTapped() async {
		let env = Environment()
		env.parentController.setMock.returns()
		env.parentController.pushMock.returns()
		let uuid = UUID()
		let expectedProject = Project(id: 1, name: "Proj")
		let expectedVersion = Version(id: uuid, buildNumber: 2, associatedTicketKeys: [])
		env.mockProjectsRepo.getProjectMock.returns(expectedProject)
		env.mockVersionsRepo.getVersionsMock.returns([expectedVersion])
		let sut = env.makeSUT()

		sut.start()

		let store: VersionsListStore = env.factory[dynamicMember: "store"]
		await store.send(.start)
		await store.send(.tapItem(VersionList.RowState(id: uuid, title: "", subtitle: "")))

		XCTAssertTrue(env.parentController.pushMock.calledOnce)
	}
}

@dynamicMemberLookup
final class LazyProxyCachingFactory<Factory> {

	private let realFactory: Factory

	private var cachedResults: [String: Any] = [:]

	init(realFactory: Factory) {
		self.realFactory = realFactory
	}

	subscript<T>(dynamicMember key: String) -> T {
		cachedResults[key] as! T
	}

	private func cached<T>(key: String, create: () -> T) -> T {
		if let cachedValue = cachedResults[key] as? T {
			return cachedValue
		}
		let newValue = create()
		cachedResults[key] = newValue
		return newValue
	}

	func cachedInstance<T>(for keyPath: KeyPath<Factory, T>) -> T {
		let key = String(describing: keyPath)
		return cached(key: key) { realFactory[keyPath: keyPath] }
	}

	func cachedMethod<ReturnType>(
		key: String,
		create: () -> ReturnType
	) -> ReturnType {
		return cached(key: key, create: create)
	}

	func cachedMethod<Input, ReturnType>(
		key: String,
		input: Input,
		create: (Input) -> ReturnType
	) -> ReturnType {
		return cached(key: key) { create(input) }
	}
}

@dynamicMemberLookup
final class CachingProxyVersionsBrowserFactory: VersionsBrowserFactory {

	private let realFactory: VersionsBrowserFactory
	private let cacheProxy: LazyProxyCachingFactory<VersionsBrowserFactory>

	init(realFactory: VersionsBrowserFactory) {
		self.realFactory = realFactory
		self.cacheProxy = LazyProxyCachingFactory(realFactory: realFactory)
	}

	subscript<T>(dynamicMember key: String) -> T {
		cacheProxy[dynamicMember: key]
	}

	func environment(
		inputParameters: (VersionsBrowserFlowInput, @MainActor @Sendable (VersionList.Environment.Output) -> Void)
	) -> VersionList.Environment {
		cacheProxy.cachedMethod(key: "environment") {
			realFactory.environment(inputParameters: inputParameters)
		}
	}

	func store(inputParameters: (VersionList.State, VersionList.Environment)) -> VersionsListStore {
		cacheProxy.cachedMethod(key: "store") {
			realFactory.store(inputParameters: inputParameters)
		}
	}

	func versionDetailsController(inputParameters: (version: CorporateTestflightDomain.Version, onTicketTapped: (CorporateTestflightDomain.Ticket) -> Void)) -> UIViewController {
		cacheProxy.cachedMethod(key: "versionDetailsController") {
			realFactory.versionDetailsController(inputParameters: inputParameters)
		}
	}

	func jiraFlowCoordinator(inputParameters: JiraViewerInterface.JiraViewerFlowInput) -> any JiraViewerInterface.JiraViewerFlowCoordinating {
		cacheProxy.cachedMethod(key: "jiraFlowCoordinator") {
			realFactory.jiraFlowCoordinator(inputParameters: inputParameters)
		}
	}
}
