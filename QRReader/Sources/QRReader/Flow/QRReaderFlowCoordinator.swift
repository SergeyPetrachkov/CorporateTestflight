import QRReaderInterface
import SwiftUI

final class QRReaderFlowCoordinator: QRReaderFlowCoordinating {

	typealias Input = QRReaderFlowInput

	private typealias QRScannerContinuation = CheckedContinuation<QRReaderFlowResult, Never>

	private let input: Input
	private var controller: UIHostingController<QRReaderView>?
	private var qrContinuation: QRScannerContinuation?

	init(input: Input) {
		self.input = input
	}

	func start() async -> QRReaderFlowResult {
		let session = input.session
		let sessionConfigurator = CaptureSessionConfigurator()
		let captureListener = QRCodeCaptureListener(session: session, sessionConfigurator: sessionConfigurator)
		let env = QRCode.Environment(
			qrListener: captureListener,
			output: { [weak self] result in
				guard let self else { return }
				qrContinuation?.resume(returning: result)
				controller?.dismiss(animated: true)
				qrContinuation = nil
			}
		)
		let state = QRCode.State(session: session)
		let store = QRReaderStore(initialState: state, environment: env)
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
