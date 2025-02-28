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