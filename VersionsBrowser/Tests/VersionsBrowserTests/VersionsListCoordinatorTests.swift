import Testing
import VersionsBrowserInterface
import SimpleDI
import UIKit
import CorporateTestflightDomain
import MockFunc
import SwiftUI
@testable import VersionsBrowser

@Suite("Versions list coordinator tests")
@MainActor
struct VersionsListCoordinatorTests {

	@MainActor
	struct Environment {

		let projectID = 1
		let container = Container()
		let parentController = ViewControllerSpy()
		let factory: CachingProxyVersionsBrowserFactory

		init() {
			self.factory = CachingProxyVersionsBrowserFactory(realFactory: VersionsBrowserFactoryImpl(resolver: container))
		}

		func makeSUT() -> VersionsListCoordinator {

			container.register(VersionsRepository.self) { _,_ in
				MockVersionsRepository()
			}

			container.register(ProjectsRepository.self) { _,_ in
				MockProjectsRepository()
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

	@Test
	func startShouldSetVC() {
		let env = Environment()
		env.parentController.setVCMock.returns()
		let sut = env.makeSUT()

		sut.start()

		#expect(env.parentController.setVCMock.input.0.last is UIHostingController<VersionsListContainer>)
		#expect(env.parentController.setVCMock.input.1)
	}

	@Test
	func outputShouldTriggerNavigation() {
		let env = Environment()
		env.parentController.setVCMock.returns()
		let sut = env.makeSUT()

		sut.start()

		// think of a type safe way to retrieve it now
		let store = env.factory
		print(store)
	}
}

final class ViewControllerSpy: UINavigationController {

	typealias Input = ([UIViewController], Bool)

	let setVCMock = MockFunc<Input, Void>()
	override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
		setVCMock.callAndReturn((viewControllers, animated))
	}
}

final class FactoryCachingProxy<FactoryType> {

	private let realFactory: FactoryType
	private var cache: [String: Any] = [:]

	init(realFactory: FactoryType) {
		self.realFactory = realFactory
	}

	private func cached<T>(key: String, create: () -> T) -> T {
		if let cachedValue = cache[key] as? T {
			return cachedValue
		}
		let newValue = create()
		cache[key] = newValue
		return newValue
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

	subscript<T>(dynamicMember keyPath: KeyPath<LazyProxyCachingFactory<VersionsBrowserFactory>, T>) -> T {
		cacheProxy[keyPath: keyPath]
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
}
