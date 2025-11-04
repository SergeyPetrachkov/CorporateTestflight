/// A base protocol for building unidirectional state containers, similar to Redux-style stores.
///
/// A `Store` owns a `State`, reacts to `Action`s, and uses an `Environment` to interact with the outside world
/// (e.g. API clients, dependencies, schedulers).
///
/// Stores are annotated with `@MainActor`, so all state mutations and actions are performed on the main thread.
/// Conforming types are usually `final class`es that also adopt `ObservableObject` so SwiftUI views can observe them.
///
/// ### Key Responsibilities
/// - Hold and publish an immutable `State` to the UI.
/// - Handle `Action`s asynchronously through `send(_:)`.
/// - Use the `Environment` to perform side effects (network calls, navigation callbacks, etc.).
///
/// ### Example
/// ```swift
/// // Define the domain
/// enum CounterAction {
///     case increment
///     case decrement
/// }
///
/// struct CounterState: Equatable {
///     var count: Int = 0
/// }
///
/// struct CounterEnvironment {
///     var analytics: AnalyticsClient
/// }
///
/// // Implement the store
/// final class CounterStore: ObservableObject, Store {
///     typealias State = CounterState
///     typealias Action = CounterAction
///     typealias Environment = CounterEnvironment
///
///     @Published private(set) var state: State
///     let environment: Environment
///
///     init(initialState: State, environment: Environment) {
///         self.state = initialState
///         self.environment = environment
///     }
///
///     func send(_ action: CounterAction) async {
///         switch action {
///         case .increment:
///             state.count += 1
///             environment.analytics.track("increment")
///         case .decrement:
///             state.count -= 1
///             environment.analytics.track("decrement")
///         }
///     }
/// }
///
/// // Usage in SwiftUI
/// struct CounterView: View {
///     @StateObject var store = CounterStore(
///         initialState: CounterState(),
///         environment: CounterEnvironment(analytics: .live)
///     )
///
///     var body: some View {
///         VStack {
///             Text("Count: \(store.state.count)")
///             HStack {
///                 Button("-") { Task { await store.send(.decrement) } }
///                 Button("+") { Task { await store.send(.increment) } }
///             }
///         }
///     }
/// }
/// ```
@available(iOS 13.0.0, *)
@MainActor
public protocol Store<State, Action>: AnyObject {
	/// Represents the state that the store manages.
	associatedtype State
	/// Represents external dependencies required by the store,
	/// such as API clients, schedulers, or navigation callbacks.
	associatedtype Environment
	/// Represents all possible actions that can be sent to the store.
	associatedtype Action

	/// The external dependencies used by this store.
	var environment: Environment { get }

	init(initialState: State, environment: Environment)

	/// Handles a given action and potentially updates the state asynchronously.
	///
	/// - Parameter action: The action to process.
	///
	/// This method is called from the UI layer (usually via a `Task` in SwiftUI).
	/// Implementations may perform side effects and publish new state values.
	func send(_ action: Action) async
}
