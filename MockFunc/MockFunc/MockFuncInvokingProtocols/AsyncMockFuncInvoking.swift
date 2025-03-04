/// An interface for a MockFunc and MockThrowingFunc that contains some syntax sugare as a default protocol implementation.
public protocol AsyncMockFuncInvoking: Actor {
	associatedtype Input

	/// A list of all arguments passed to the mocked function.
	var invocations: [Input] { get }
}

public extension AsyncMockFuncInvoking {
	/// How many times the function was called. The value is calculated based on `invocations.count`.
	var count: Int {
		invocations.count
	}

	/// `True` if the function was called at least once. The value is calculated based on `invocations.count`.
	var called: Bool {
		!invocations.isEmpty
	}

	/// `True` if the function was called exactly once. The value is calculated based on `invocations.count`.
	var calledOnce: Bool {
		count == 1
	}

	/// Input arguments that were passed to the function last time
	var input: Input {
		invocations[count - 1]
	}
}
