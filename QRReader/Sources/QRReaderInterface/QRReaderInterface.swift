import AVFoundation
import UniFlow
import UIKit

public protocol QRReaderFlowCoordinating: FlowEngine where Output == QRReaderFlowResult { }

public struct QRReaderFlowInput {

	public let session: AVCaptureSession
	public let parentViewController: UIViewController

	public init(session: AVCaptureSession, parentViewController: UIViewController) {
		self.session = session
		self.parentViewController = parentViewController
	}
}

public enum QRReaderFlowResult: Sendable {
	case cancelled
	case codeRetrieved(String)
}
