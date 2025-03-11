import SwiftUI

@available(iOS 16.0, *)
struct QRReaderView: View {

	@ObservedObject private var store: QRReaderStore

	init(store: QRReaderStore) {
		self.store = store
	}

	var body: some View {
		NavigationView {
			contentView
				.task {
					await store.send(.start)
				}
				.navigationTitle("QR Scanner")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItemGroup(placement: .primaryAction) {
						Button("Close") {
							Task {
								await store.send(.stop)
							}
						}
					}
				}
		}
	}

	private var contentView: some View {
#if targetEnvironment(simulator)
		ZStack {
			Image(uiImage: generateImage())
				.interpolation(.none)
				.resizable()
				.scaledToFit()
				.frame(width: 200, height: 200)
			overlayView
		}
#else
		ScannerView(captureSession: store.state.session)
			.overlay(overlayView)
#endif
	}

	private var overlayView: some View {
		ScannerOverlayView()
			.overlay {
				if let scannedCode = store.state.scannedCode {
					VStack {
						Spacer()
						Text("Open '\(scannedCode)'")
							.padding()
							.background(Color.white)
							.cornerRadius(10)
							.padding()
					}
					.onTapGesture {
						Task {
							await store.send(.tapScannedContent(scannedCode))
						}
					}
				}
			}
	}
}
