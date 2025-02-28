import AVFoundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
public struct QRReaderView: View {
	@StateObject private var store: QRReaderStore

	init(store: QRReaderStore) {
		self._store = .init(wrappedValue: store)
	}

	public var body: some View {
		ScannerView(captureSession: store.state.session)
			.overlay {
				if let scannedCode = store.state.scannedCode {
					VStack {
						Spacer()
						Text("Scanned QR Code: \(scannedCode)")
							.padding()
							.background(Color.white)
							.cornerRadius(10)
							.padding()
					}
				}
			}
			.task {
				await store.send(.start)
			}
	}
}

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
