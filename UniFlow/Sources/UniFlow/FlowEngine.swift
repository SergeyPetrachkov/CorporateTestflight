@available(iOS 13.0.0, *)
@MainActor
public protocol FlowEngine {
	associatedtype Input
	associatedtype Output

	init(input: Input)

	func start() async -> Output
}
