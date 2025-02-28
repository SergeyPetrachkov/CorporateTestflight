import AVFoundation
import Foundation

struct CaptureSessionConfigurator {

	func setupSession(session: AVCaptureSession, captureOutputDelegate: AVCaptureMetadataOutputObjectsDelegate) {

		guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
			print("You're trying to launch QR Reader on a simulator. No can do!")
			return
		}
		guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice), session.canAddInput(videoInput) else {
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
