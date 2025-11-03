@available(iOS 13.0.0, *)
@MainActor
public protocol Store<State, Action>: AnyObject {
	associatedtype State
	associatedtype Environment
	associatedtype Action

	var environment: Environment { get }

	init(initialState: State, environment: Environment)

	func send(_ action: Action) async
}
