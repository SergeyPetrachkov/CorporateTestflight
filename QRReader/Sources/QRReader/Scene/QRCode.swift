import AVFoundation
import QRReaderInterface

enum QRCode {
	enum Action {
		case start
		case stop
		case tapScannedContent(String)
	}

	struct Environment {
		let qrListener: QRCodeCaptureListening
		let output: (QRReaderFlowResult) -> Void
	}

	struct State: @unchecked Sendable {
		var scannedCode: String?
		var session: AVCaptureSession  // this is not sendable, but we don't care

		init(scannedCode: String? = nil, session: AVCaptureSession) {
			self.scannedCode = scannedCode
			self.session = session
		}
	}
}
