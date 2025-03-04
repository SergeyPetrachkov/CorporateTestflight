import CorporateTestflightDomain
import ImageLoader
import UniFlow
import UIKit

public protocol JiraViewerFlowCoordinating: SyncFlowEngine {
	func start()
}

public struct JiraViewerFlowInput {
	public let ticket: Ticket
	public let parentViewController: UIViewController
	public let imageLoader: ImageLoader

	public init(ticket: Ticket, parentViewController: UIViewController, imageLoader: ImageLoader) {
		self.ticket = ticket
		self.parentViewController = parentViewController
		self.imageLoader = imageLoader
	}
}
