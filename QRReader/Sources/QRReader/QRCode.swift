//
//  QRCode.swift
//  QRReader
//
//  Created by Sergey Petrachkov on 28.02.2025.
//


public enum QRCode {
	public enum Action {
		case start
		case stop
	}

	public struct Environment {
		let qrListener: QRCodeCaptureListener

		public init(qrListener: QRCodeCaptureListener) {
			self.qrListener = qrListener
		}
	}

	public struct State {
		var scannedCode: String?
		var session: AVCaptureSession

		public init(scannedCode: String? = nil, session: AVCaptureSession) {
			self.scannedCode = scannedCode
			self.session = session
		}
	}
}