import AVFoundation
import QRReaderInterface
import SwiftUI
import SimpleDI

final class QRReaderFlowCoordinator: QRReaderFlowCoordinating {

	typealias Input = QRReaderFlowInput
	typealias Output = QRReaderFlowResult

	private typealias QRScannerContinuation = CheckedContinuation<QRReaderFlowResult, Never>

	private let input: Input
	private let factory: QRReaderFlowFactory

	private var controller: UIHostingController<QRReaderView>?
	private var qrContinuation: QRScannerContinuation?

	var output: ((Output) -> Void)?

	init(input: Input, factory: QRReaderFlowFactory) {
		self.input = input
		self.factory = factory
	}

	func start() {
		let session = factory.session()
		let captureListener = factory.capturingListener(inputParameters: session)
		let initialState = QRCode.State(session: session)
		let sceneOutput: (Output) -> Void = { [weak self] result in
			guard let self else { return }
			controller?.dismiss(animated: true)
			output?(result)
		}
		let environment = factory.environment(inputParameters: (captureListener, sceneOutput))
		let store = factory.store(inputParameters: (initialState, environment))
		let view = QRReaderView(store: store)
		let hostingVC = UIHostingController(rootView: view)
		hostingVC.isModalInPresentation = true
		controller = hostingVC
		input.parentViewController.present(hostingVC, animated: true)
	}

	// _disfavoredOverload doesn't work with tests, so I renamed the function
	@_disfavoredOverload
	func startAsync() async -> QRReaderFlowResult {
		let session = factory.session()
		let captureListener = factory.capturingListener(inputParameters: session)
		let initialState = QRCode.State(session: session)
		let sceneOutput = { [weak self] result in
			guard let self else { return }
			qrContinuation?.resume(returning: result)
			controller?.dismiss(animated: true)
			qrContinuation = nil
		}

		let environment = factory.environment(inputParameters: (captureListener, sceneOutput))
		let store = factory.store(inputParameters: (initialState, environment))
		let view = QRReaderView(store: store)
		let hostingVC = UIHostingController(rootView: view)
		hostingVC.isModalInPresentation = true
		controller = hostingVC
		input.parentViewController.present(hostingVC, animated: true)

		return await withCheckedContinuation { (continuation: QRScannerContinuation) in
			qrContinuation = continuation
		}
	}
}
