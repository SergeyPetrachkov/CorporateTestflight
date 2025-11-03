/// A container for completion handlers, allowing for more structured management of
/// asynchronous callbacks in mocked functions.
public enum CompletionContainer<Output> {
	/// Stored closure was non‑isolated (no actor context required).
	case nonisolated((Output) -> Void)
	/// Stored closure was actor‑isolated. Holds:
	/// - The actor instance whose isolation must be active at call time
	/// - A function expecting `(actor, Output)` invoked only when already isolated
	case isolated (any Actor, BackportCompletionContainer<Output>)

	/// Initializer that captures and classifies an `@isolated(any)` closure.
	///
	/// - Performs runtime availability check (feature only valid on iOS 18 / macOS 15+).
	/// - Uses `fn.isolation` to branch and bitcast into one of two storage strategies.
	/// - Traps if runtime invariants are violated (unexpected layout or unsupported OS).
	public init(
		_ fn: @escaping @isolated(any) (Output) -> Void
	) {
		// In the modern Swift Runtime, isolation is also a part of the type.
		// Since we're only running tests on the latest iOS versions, it's fine to trap.
		// If you need to use closures on older iOS versions,
		// don't store them in `CompletionContainer`.
		// Make closures a part of the `input` and invoke them yourself.
		// Isolated completion handlers cannot be flattened to be used synchronously.
		// The complete discussion with more details can be found here: https://forums.swift.org/t/isolated-any-evolution-and-current-limitations/81923
		guard #available(macOS 15.0, iOS 18.0, *) else { fatalError("Unsupported runtime!") }

		typealias OriginalFunction = @isolated(any) (Output) -> Void
		typealias NonIsolatedFunction = (Output) -> Void

		assert(MemoryLayout<NonIsolatedFunction>.size == MemoryLayout<OriginalFunction>.size)
		let erasedFunction = unsafe unsafeBitCast(fn, to: NonIsolatedFunction.self)
		switch fn.isolation {
		case .none:
			self = .nonisolated(erasedFunction)
		case .some(let actor):
			self = .isolated(actor, BackportCompletionContainer(erasedFunction))
		}
	}

	/// Invokes the stored completion with `output`, enforcing isolation rules:
	/// - For `.isolated`, the caller must already be executing on the stored actor.
	///   A failed precondition indicates incorrect use (missing `await actor` hop).
	/// - For `.nonisolated`, the closure is executed directly.
	public func callAsFunction(_ output: Output) -> Void {
		switch self {
		case .nonisolated(let fn):
			return fn(output)
		case .isolated(let actor, let fn):
			actor.preconditionIsolated("Incorrect isolation assumption!")
			return fn(output)
		}
	}
}

/// Calls the underlying completion handler with the provided output.
///
/// This method is inlined to eliminate function call overhead, making
/// `container(output)` equivalent to `container.completion(output)` in performance
/// but with better encapsulation and consistent API design.
///
/// - Parameter output: The output value to pass to the completion handler
///
/// - Important:
/// We ideally want to only have this in our codebase and ban isolated completion handlers.
public struct BackportCompletionContainer<Output> {

	let completion: (Output) -> Void

	public init(_ completion: @escaping (Output) -> Void) {
		self.completion = completion
	}

	@inline(__always)
	public func callAsFunction(_ output: Output) {
		completion(output)
	}
}
