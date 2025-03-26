import AVFoundation
import Combine
import UniFlow
import AsyncAlgorithms

// Plan:
// Async algorithms
// Simple Store

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
		print("'action: \(action)' >> 'state: \(state)'")
		switch action {
		case .start:
			for await code in environment.qrListener.startStream().removeDuplicates() {
				AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
				state.scannedCode = code
			}
		case .stop:
			environment.qrListener.stop()
			environment.output(.cancelled)
		case .tapScannedContent(let string):
			environment.output(.codeRetrieved(string))
		}
	}
}

