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
		print("'action: \(action)' >> 'state: \(state)'")
		switch action {
		case .start:
#if targetEnvironment(simulator)
			state.scannedCode = "ticket:JIRA-4"
#else
			for await code in environment.qrListener.startStream().removeDuplicates() {
				print("code: \(code)")
				AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
				state.scannedCode = code
			}
#endif
		case .stop:
			environment.qrListener.stop()
			environment.output(.cancelled)
		case .tapScannedContent(let string):
			environment.output(.codeRetrieved(string))
		}
	}
}
