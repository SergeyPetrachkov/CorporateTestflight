// Plan: 5
// Coordination approaches async/sync

@available(iOS 13.0.0, *)
@MainActor
public protocol FlowEngine: AnyObject {
	associatedtype Input
	associatedtype Output

	func start() async -> Output
}

@available(iOS 13.0.0, *)
@MainActor
public protocol SyncFlowEngine: AnyObject {
	associatedtype Input

	func start()
}
