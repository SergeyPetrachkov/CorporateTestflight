import CorporateTestflightDomain
import UIKit
import UniFlow
import SimpleDI

public protocol VersionsBrowserCoordinator: SyncFlowEngine {
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
