@MainActor
public protocol Store: AnyObject {
	associatedtype State
	associatedtype Environment
	associatedtype Action

	var environment: Environment { get }

	init(initialState: State, environment: Environment)

	func send(_ action: Action) async
}
