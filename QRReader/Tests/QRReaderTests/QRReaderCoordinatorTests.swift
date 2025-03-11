import AVFoundation
import MockFunc
import QRReaderInterface
import UIKit
import SimpleDI
import XCTest
import SwiftUI

@testable import QRReader

@MainActor
final class QRReaderCoordinatorTests: XCTestCase {

	@MainActor
	struct Environment {

		let container = Container()
		let parentViewController = ViewControllerSpy()

		let factory: FactoryCachingProxy

		init() {
			self.factory = FactoryCachingProxy(resolver: container)
		}

		func makeSUT() -> QRReaderFlowCoordinator {
			parentViewController.presentMock.returns()

			return QRReaderFlowCoordinator(
				input: QRReaderFlowInput(
					parentViewController: parentViewController
				),
				factory: factory
			)
		}
	}


	func test_coordinatorPresentsCorrectlyConfiguredView() async {
		// Given
		let env = Environment()
		let sut = env.makeSUT()

		// When

		sut.start()

		// Then
		XCTAssertTrue(env.parentViewController.presentMock.calledOnce)
		XCTAssertTrue(env.parentViewController.presentMock.input.0.wrappedValue is UIHostingController<QRReaderView>)
		XCTAssertTrue(env.parentViewController.presentMock.input.0.wrappedValue?.isModalInPresentation ?? false)
	}


	func test_coordinatorResultsWithCancellation() async {

		let env = Environment()
		let sut = env.makeSUT()
		let exp = expectation(description: "Output called")
		sut.output = { result in
			XCTAssertTrue(result == .cancelled)
			exp.fulfill()
		}

		sut.start()
		
		await env.factory._store.send(.stop)
		await fulfillment(of: [exp], timeout: 1)
	}

	func test_coordinatorResultsWithQRCode() async {

		let env = Environment()
		let sut = env.makeSUT()
		let exp = expectation(description: "Output called")
		sut.output = { result in
			XCTAssertTrue(result == .codeRetrieved("Content"))
			exp.fulfill()
		}


		sut.start()

		await env.factory._store.send(.tapScannedContent("Content"))
		await fulfillment(of: [exp], timeout: 1)
	}

	func test_asyncStart() async throws {

		let env = Environment()
		let sut = env.makeSUT()

		async let startTask = sut.startAsync()
		try await Task.sleep(nanoseconds: 10_000)

		await env.factory._store.send(.tapScannedContent("Content"))
		let result = await startTask
		XCTAssertTrue(result == .codeRetrieved("Content"))
	}
}

final class FactoryCachingProxy: QRReaderFlowFactory {

	let realFactory: QRReaderFlowFactoryImpl

	init(resolver: Resolver) {
		realFactory = QRReaderFlowFactoryImpl(resolver: resolver)
	}

	private(set) var _session: AVCaptureSession!
	func session() -> AVCaptureSession {
		let value = _session ?? realFactory.session()
		_session = value
		return value
	}

	private(set) var _capturingListener: (any QRReader.QRCodeCaptureListening)!
	func capturingListener(inputParameters: AVCaptureSession) -> any QRReader.QRCodeCaptureListening {
		let value = _capturingListener ?? realFactory.capturingListener(inputParameters: inputParameters)
		_capturingListener = value
		return value
	}

	private(set) var _environment: QRReader.QRCode.Environment!
	func environment(inputParameters: (any QRReader.QRCodeCaptureListening, (QRReaderInterface.QRReaderFlowResult) -> Void)) -> QRReader.QRCode.Environment {
		let value = _environment ?? realFactory.environment(inputParameters: inputParameters)
		_environment = value
		return value
	}

	private(set) var _store: QRReader.QRReaderStore!
	func store(inputParameters: (QRReader.QRCode.State, QRReader.QRCode.Environment)) -> QRReader.QRReaderStore {
		let value = _store ?? realFactory.store(inputParameters: inputParameters)
		_store = value
		return value
	}
}

final class WeakRef<T: AnyObject> {
	weak var wrappedValue: T?

	init(_ wrappedValue: T? = nil) {
		self.wrappedValue = wrappedValue
	}
}

final class ViewControllerSpy: UIViewController {

	typealias Input = (WeakRef<UIViewController>, Bool)

	let presentMock = MockFunc<Input, Void>()

	override func present(
		_ viewControllerToPresent: UIViewController,
		animated flag: Bool,
		completion: (() -> Void)? = nil
	) {
		presentMock.callAndReturn((WeakRef(viewControllerToPresent), flag))
	}
}


final class MockQRReaderFlowFactory: QRReaderFlowFactory {

	let sessionMock = MockFunc<Void, AVCaptureSession>()
	func session() -> AVCaptureSession {
		sessionMock.callAndReturn()
	}

	let mockCapturingListener = MockFunc<AVCaptureSession, any QRReader.QRCodeCaptureListening>()
	func capturingListener(inputParameters: AVCaptureSession) -> any QRReader.QRCodeCaptureListening {
		mockCapturingListener.callAndReturn(inputParameters)
	}

	let mockEnvironment = MockFunc<(any QRCodeCaptureListening, (QRReaderFlowResult) -> Void), QRCode.Environment>()
	func environment(inputParameters: (any QRCodeCaptureListening, (QRReaderFlowResult) -> Void)) -> QRCode.Environment {
		mockEnvironment.callAndReturn(inputParameters)
	}

	let mockStore = MockFunc<(QRCode.State, QRCode.Environment), QRReader.QRReaderStore>()
	func store(inputParameters: (QRReader.QRCode.State, QRReader.QRCode.Environment)) -> QRReader.QRReaderStore {
		mockStore.callAndReturn(inputParameters)
	}
}

final class StubQRCodeCaptureListening: QRCodeCaptureListening {
	func start() {

	}

	func stop() {

	}

	func startStream() -> AsyncStream<String> {
		AsyncStream { continuation in
			continuation.yield("JIRA-4")
			continuation.finish()
		}
	}
}
