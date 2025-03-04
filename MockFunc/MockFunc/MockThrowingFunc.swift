import Foundation

/// This is a class that encapsulates Mock logic for any throwing non-async function that receives input of a certain type and produces output of a given type.
/// There is a separate object for throwing functions because otherwise if we used one universal object for all cases it would become less convenient to work with for non-throwing cases.
///
///	- Note: This mock can be used for async functions, but it's important to understand that the Mock class is not thread-safe and is only safe to use outside of highly concurrent contexts.
///
/// To start using mock, one needs to provide the `result` closure.
///
/// There are two ways to use it: by manually specifying types for the mock or by using convenience function `mock` that will make compiler infer the type.
/// Sometimes (when dealing with closures) latter approach won't work, so it's recommended to use former.
/// ```swift
/// final class MockSomeAPI: SomeAPIProtocol {
///
///   let searchMock = MockThrowingFunc<(String, [String: String]?), SearchResponse>()
///   func search(query: String, attributes: [String: String]?, completion: @escaping (SearchResponse) throws -> Void) throws {
///	     try searchMock.callAndReturn((query, attributes), completion: completion)
///   }
///   let asyncLookupMock = MockThrowingFunc<String, SearchResponse>()
///   func asyncLookup(id: String) async throws -> SearchResponse {
///	     try asyncLookupMock.callAndReturn(id)
///   }
/// }
/// ```
public final class MockThrowingFunc<Input, Output>: MockFuncInvoking, @unchecked Sendable {

	// MARK: - Properties

	/// A callback that is triggered when the mocked function is called.
	private var didCall: (Input) throws -> Void = { _ in }

	/// A list of all arguments passed to the mocked function.
	public private(set) var invocations: [Input] = []

	/// A list of all completion closures called from the mocked function.
	public private(set) var completions: [(Output) throws -> Void] = []

	/// A way to inject the result. This is a required property to set up before using the mock function.
	public private(set) var result: (Input) throws -> Output

	/// When testing closure-based functions, this flag indicates if the completion closure should be triggered immediately (if set to true) or just put into `completions` if set to false.
	///
	/// Default value is true.
	public var callsCompletionImmediately = true

	/// The result of the mocked function
	public var output: Output {
		get throws {
			try result(input)
		}
	}

	/// The last completion closure
	public var completion: (Output) throws -> Void {
		get throws {
			completions[count - 1]
		}
	}

	// MARK: - Init

	/// Create an instance of mock.
	/// - Parameters:
	///		- function: in our setup the #function will return the name of the Mock as all the mocks will be instantiated during the allocation of the mocked entity.
	///		- line: line that will point to the exact place in file where this Mock was instantiated.
	public init(function: StaticString = #function, line: Int = #line) {
		result = { _ in fatalError("You must provide a result handler before using MockFunc instantiated at line: \(line) of \(function)") }
	}

	// MARK: - Class interface

	/// Triggering this function will append input to the list of invocations, trigger `didCall` callback, and then trigger `result` when returning `output` from this function.
	///
	///	- Note: Normally, this one gets called from the generated code, unless you write the mocks yourself.
	///
	///	```swift
	///	let removePersistentDomainForNameMock = MockFunc<(String), Void>()
	///	func removePersistentDomain(forName: String) {
	///	    removePersistentDomainForNameMock.callAndReturn(forName)
	///	}
	///	```
	///	- Parameters:
	/// 	- input: arguments of the mocked function.
	public func callAndReturn(_ input: Input) throws -> Output {
		try call(with: input)
		return try output
	}

	/// Use this function when mocking closure-based function.
	///
	/// Triggering this function will:
	/// 1) append input to the list of invocations
	/// 2) trigger `didCall` callback
	/// 3) append completion to the `completions`
	/// 4) then trigger `result` when passing `output` to the completion if `callsCompletionImmediately` is set to true.
	///
	///	- Parameters:
	/// 	- input: arguments of the mocked function.
	public func callAndReturn(
		_ input: Input,
		completion: @escaping @isolated(any) (Output) throws -> Void
	) throws {
		try call(with: input)
		try storeCompletionAndCallIfNeeded(completion, output: try output)
	}

	/// Get notified when a function is called. The function's input will be provided inside the closure.
	///
	///	- Note: This is a good place to put your `expectation.fulfill()` call if you need one.
	/// - Parameters:
	/// 	- closure: A callback that will be triggered when the mocked function is called.
	public func whenCalled(closure: @escaping @isolated(any) (Input) throws -> Void) {
		didCall = closure
	}

	// MARK: - Private mock logic

	/// Triggering this function will append input to the list of invocations and trigger `didCall` callback.
	///
	///	- Parameters:
	/// 	- input: arguments of the mocked function.
	private func call(with input: Input) throws {
		invocations.append(input)
		try didCall(input)
	}

	private func storeCompletionAndCallIfNeeded(
		_ completion: @escaping (Output) throws -> Void,
		output: @autoclosure () throws -> Output
	) throws {
		completions.append(completion)
		if callsCompletionImmediately {
			try completion(try output())
		}
	}
}

// MARK: - Convenience

public extension MockThrowingFunc {

	/// Set the result of the mocked function.
	///
	/// How to use it:
	/// ```swift
	/// searchMock.returns(SearchResult(id: "1"))
	/// ```
	func returns(_ value: Output) {
		result = { _ in value }
	}

	/// Set the result of the mocked function. For Void functions it's still necessary to provide the result, otherwise the mock is not considered configured.
	///
	/// How to use it:
	/// ```swift
	/// searchMock.returns()
	/// ```
	func returns() where Output == Void {
		result = { _ in () }
	}

	/// Set the result of the mocked function to `nil`.
	///
	/// If your function returns an optional, and you want to mock nil, this is a shorthand function to set the mock up.
	///
	/// How to use it:
	/// ```swift
	/// searchMock.returnsNil()
	/// ```
	func returnsNil<T>() where Output == T? {
		result = { _ in nil }
	}

	/// Set the error that must be thrown instead of the result of the mocked function.
	///
	/// How to use it:
	/// ```swift
	/// searchMock.throws(Error.testError)
	/// ```
	func `throws`(_ error: Error) {
		result = { _ in throw error }
	}
}
