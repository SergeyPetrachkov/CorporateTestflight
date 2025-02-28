import QRReaderInterface
import SwiftUI

final class QRReaderFlowCoordinator: QRReaderFlowCoordinating {

	typealias Input = QRReaderFlowInput

	private let input: Input

	init(input: Input) {
		self.input = input
	}

	func start() {
		let session = input.session
		let sessionConfigurator = CaptureSessionConfigurator()
		let captureListener = QRCodeCaptureListener(session: session, sessionConfigurator: sessionConfigurator)
		let env = QRCode.Environment(qrListener: captureListener)
		let state = QRCode.State(session: session)
		let store = QRReaderStore(initialState: state, environment: env)
		let view = QRReaderView(store: store)
		let hostingVC = UIHostingController(rootView: view)
		input.parentViewController.present(hostingVC, animated: true)
	}
}
