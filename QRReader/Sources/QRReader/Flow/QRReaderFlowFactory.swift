import AVFoundation
import SimpleDI
import QRReaderInterface

@MainActor
protocol QRReaderFlowFactory {
	func session() -> AVCaptureSession
	func capturingListener(inputParameters: AVCaptureSession) -> QRCodeCaptureListening
	func environment(inputParameters: (QRCodeCaptureListening, (QRReaderFlowResult) -> Void)) -> QRCode.Environment
	func store(inputParameters: (QRCode.State, QRCode.Environment)) -> QRReaderStore
}

final class QRReaderFlowFactoryImpl: QRReaderFlowFactory {
	private let resolver: Resolver

	init(resolver: Resolver) {
		self.resolver = resolver
	}

	func session() -> AVCaptureSession {
		AVCaptureSession()
	}

	func capturingListener(inputParameters: AVCaptureSession) -> QRCodeCaptureListening {
		#if targetEnvironment(simulator)
			QRCodeCaptureSimulatorListener()
		#else
			QRCodeCaptureListener(session: inputParameters, sessionConfigurator: CaptureSessionConfigurator())
		#endif
	}

	func environment(inputParameters: (QRCodeCaptureListening, (QRReaderFlowResult) -> Void)) -> QRCode.Environment {
		QRCode.Environment(
			qrListener: inputParameters.0,
			output: inputParameters.1
		)
	}

	func store(inputParameters: (QRCode.State, QRCode.Environment)) -> QRReaderStore {
		QRReaderStore(initialState: inputParameters.0, environment: inputParameters.1)
	}
}
