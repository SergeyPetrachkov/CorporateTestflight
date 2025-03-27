import CorporateTestflightDomain
import SimpleDI
import UniFlow
import UIKit

public protocol JiraViewerFlowCoordinating: SyncFlowEngine where Input == JiraViewerFlowInput { }

public struct JiraViewerFlowInput {
	public let ticket: Ticket
	public let parentViewController: UIViewController
	public let resolver: Resolver

	public init(ticket: Ticket, parentViewController: UIViewController, resolver: Resolver) {
		self.ticket = ticket
		self.parentViewController = parentViewController
		self.resolver = resolver
	}
}
