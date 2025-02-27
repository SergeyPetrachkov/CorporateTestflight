import AVFoundation
import Combine
import UniFlow
import AsyncAlgorithms

public final class QRReaderStore: Store, ObservableObject {
	public typealias State = QRCode.State
	public typealias Environment = QRCode.Environment
	public typealias Action = QRCode.Action

	public let environment: Environment
	@Published var state: State


	public init(initialState: State, environment: Environment) {
		self.environment = environment
		self.state = initialState
	}

	public func send(_ action: Action) async {
		switch action {
		case .start:
			for await code in environment.qrListener.startQRCodesStream().removeDuplicates() {
				print("code: \(code)")
				AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
				state.scannedCode = code
			}
		case .stop:
			environment.qrListener.stop()
		}
	}
}

public enum QRCode {
	public enum Action {
		case start
		case stop
	}

	public struct Environment {
		let qrListener: QRCodeCaptureListener

		public init(qrListener: QRCodeCaptureListener) {
			self.qrListener = qrListener
		}
	}

	public struct State {
		var scannedCode: String?
		var session: AVCaptureSession

		public init(scannedCode: String? = nil, session: AVCaptureSession) {
			self.scannedCode = scannedCode
			self.session = session
		}
	}
}

