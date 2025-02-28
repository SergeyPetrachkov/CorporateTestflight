import AVFoundation

enum QRCode {
	enum Action {
		case start
		case stop
	}

	struct Environment {
		let qrListener: QRCodeCaptureListener

		public init(qrListener: QRCodeCaptureListener) {
			self.qrListener = qrListener
		}
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
