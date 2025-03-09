import AVFoundation
import SwiftUI
import UIKit

struct ScannerView: UIViewControllerRepresentable {

	let captureSession: AVCaptureSession

	func makeUIViewController(context: Context) -> UIViewController {
		let viewController = UIViewController()

		let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		previewLayer.frame = viewController.view.bounds
		previewLayer.videoGravity = .resizeAspectFill
		viewController.view.layer.addSublayer(previewLayer)

		return viewController
	}

	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
