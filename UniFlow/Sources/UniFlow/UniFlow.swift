// Plan: 4 Uni Store
// The SwiftUI uniflow arch. Opinionated solution, but acts as a guardrail to unify the codebase

@available(iOS 13.0.0, *)
@MainActor
public protocol Store: AnyObject {
	associatedtype State
	associatedtype Environment
	associatedtype Action

	var environment: Environment { get }

	init(initialState: State, environment: Environment)

	func send(_ action: Action) async
}
