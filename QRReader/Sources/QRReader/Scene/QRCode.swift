import AVFoundation
import QRReaderInterface

enum QRCode {
	enum Action {
		case start
		case stop
		case tapScannedContent(String)
	}

	struct Environment {
		let qrListener: QRCodeCaptureListener
		let output: (QRReaderFlowResult) -> Void
	}

	struct State {
		var scannedCode: String?
		var session: AVCaptureSession

		init(scannedCode: String? = nil, session: AVCaptureSession) {
			self.scannedCode = scannedCode
			self.session = session
		}
	}
}
