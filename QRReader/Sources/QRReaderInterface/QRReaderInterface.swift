import UniFlow
import UIKit

public protocol QRReaderFlowCoordinating: SyncFlowEngine where Input == QRReaderFlowInput {

	var output: ((QRReaderFlowResult) -> Void)? { get set }
	func start()
	func startAsync() async -> QRReaderFlowResult
}

public struct QRReaderFlowInput {

	public let parentViewController: UIViewController

	public init(parentViewController: UIViewController) {
		self.parentViewController = parentViewController
	}
}

public enum QRReaderFlowResult: Sendable, Equatable {
	case cancelled
	case codeRetrieved(String)
}
