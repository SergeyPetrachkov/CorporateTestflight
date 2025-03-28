import AVFoundation
import Foundation

// Plan: 13 Async <-> Legacy bridge
// Just a demonstration. Nothing to be written here
// AsyncStream
// Unchecked Sendable
// Continuation

protocol QRCodeCaptureListening: AnyObject {
	func start()

	func stop()

	func startStream() -> AsyncStream<String>
}

#if targetEnvironment(simulator)
	final class QRCodeCaptureSimulatorListener: QRCodeCaptureListening {
		func start() {}

		func stop() {}

		func startStream() -> AsyncStream<String> {
			AsyncStream { continuation in
				continuation.yield("ticket:JIRA-1")
				continuation.finish()
			}
		}
	}
#endif

final class QRCodeCaptureListener: NSObject, QRCodeCaptureListening, AVCaptureMetadataOutputObjectsDelegate, @unchecked Sendable {

	let session: AVCaptureSession
	let sessionConfigurator: CaptureSessionConfigurator

	var onCodeCaptured: (@Sendable (String) -> Void)?

	init(session: AVCaptureSession, sessionConfigurator: CaptureSessionConfigurator) {
		self.session = session
		self.sessionConfigurator = sessionConfigurator
	}

	deinit {
		print("❌ deinit \(self)")
	}

	func start() {
		if session.isRunning { return }
		sessionConfigurator.setupSession(session: session, captureOutputDelegate: self)
		DispatchQueue.global(qos: .userInitiated).async {
			self.session.startRunning()
		}
	}

	func stop() {
		if session.isRunning {
			DispatchQueue.global(qos: .userInitiated).async {
				self.session.stopRunning()
			}
		}
	}

	func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
		if let metadataObject = metadataObjects.first {
			guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
			guard let stringValue = readableObject.stringValue else { return }
			onCodeCaptured?(stringValue)
		}
	}

	func startStream() -> AsyncStream<String> {
		AsyncStream { continuation in
			let listener = self
			listener.onCodeCaptured = { code in
				continuation.yield(code)
			}
			continuation.onTermination = { _ in
				print("I'm about to be terminated")
				listener.session.stopRunning()
			}
			listener.start()
		}
	}
}
