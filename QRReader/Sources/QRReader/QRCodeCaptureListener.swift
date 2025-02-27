import AVFoundation
import Foundation

public struct CaptureSessionConfigurator {

	public init() {}

	func setupSession(session: AVCaptureSession, captureOutputDelegate: AVCaptureMetadataOutputObjectsDelegate) {

		let videoCaptureDevice = AVCaptureDevice.default(for: .video)
		guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice!), session.canAddInput(videoInput) else {
			return
		}
		session.addInput(videoInput)

		let metadataOutput = AVCaptureMetadataOutput()
		guard session.canAddOutput(metadataOutput) else {
			return
		}
		session.addOutput(metadataOutput)

		metadataOutput.setMetadataObjectsDelegate(captureOutputDelegate, queue: DispatchQueue.main)
		metadataOutput.metadataObjectTypes = [.qr]
	}
}

public final class QRCodeCaptureListener: NSObject, AVCaptureMetadataOutputObjectsDelegate, @unchecked Sendable {

	let session: AVCaptureSession
	let sessionConfigurator: CaptureSessionConfigurator

	var onCodeCaptured: (@Sendable (String) -> Void)?

	public init(session: AVCaptureSession, sessionConfigurator: CaptureSessionConfigurator) {
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

	public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
		if let metadataObject = metadataObjects.first {
			guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
			guard let stringValue = readableObject.stringValue else { return }
			onCodeCaptured?(stringValue)
		}
	}

	func startQRCodesStream() -> AsyncStream<String> {
		AsyncStream { continuation in
			let listener = self
			listener.onCodeCaptured = { code in
				continuation.yield(code)
			}
			continuation.onTermination = { _ in
				listener.session.stopRunning()
			}
			listener.start()
		}
	}
}
