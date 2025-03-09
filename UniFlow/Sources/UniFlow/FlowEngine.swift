@available(iOS 13.0.0, *)
@MainActor
public protocol FlowEngine: AnyObject {
	associatedtype Input
	associatedtype Output

	init(input: Input)

	func start() async -> Output
}


@available(iOS 13.0.0, *)
@MainActor
public protocol SyncFlowEngine {
	associatedtype Input

	init(input: Input)

	func start()
}
