import CorporateTestflightDomain
import UIKit
import UniFlow
import SimpleDI

// Plan 6: Interface module
// Interface of the VersionsBrowser, output of the coordinator
public protocol VersionsBrowserCoordinator: SyncFlowEngine where Input == VersionsBrowserFlowInput {
	var output: ((VersionsBrowserOutput) -> Void)? { get set }
}

public struct VersionsBrowserFlowInput {
	public let projectId: Project.ID
	public let parentViewController: UINavigationController
	public let resolver: Resolver

	public init(projectId: Project.ID, parentViewController: UINavigationController, resolver: Resolver) {
		self.projectId = projectId
		self.parentViewController = parentViewController
		self.resolver = resolver
	}
}

public enum VersionsBrowserOutput {
	case qrRequested
}
