import AVFoundation
import UniFlow
import UIKit

public protocol QRReaderFlowCoordinating: SyncFlowEngine {

}

public struct QRReaderFlowInput {

	public let session: AVCaptureSession
	public let parentViewController: UIViewController

	public init(session: AVCaptureSession, parentViewController: UIViewController) {
		self.session = session
		self.parentViewController = parentViewController
	}
}
