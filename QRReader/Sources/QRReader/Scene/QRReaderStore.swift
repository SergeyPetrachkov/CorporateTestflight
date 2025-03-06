import AVFoundation
import Combine
import UniFlow
import AsyncAlgorithms

final class QRReaderStore: Store, ObservableObject {
	typealias State = QRCode.State
	typealias Environment = QRCode.Environment
	typealias Action = QRCode.Action

	let environment: Environment
	@Published var state: State

	init(initialState: State, environment: Environment) {
		self.environment = environment
		self.state = initialState
	}

	deinit {
		print("❌ deinit \(self)")
	}

	func send(_ action: Action) async {
		switch action {
		case .start:
			for await code in environment.qrListener.startStream().removeDuplicates() {
				print("code: \(code)")
				AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
				state.scannedCode = code
			}
		case .stop:
			environment.qrListener.stop()
		}
	}
}
