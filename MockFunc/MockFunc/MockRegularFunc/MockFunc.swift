import Foundation

/// This is a class that encapsulates Mock logic for any non-throwing function that receives input of a certain type and produces output of a given type.
///
///	- Note: This mock can be used for async functions, but it's important to understand that the Mock class is not thread-safe and is only safe to use outside of highly concurrent contexts. For concurrent scenarios, use `ThreadSafeMockFunc` instead.

/// To start using mock, one needs to provide the `result` closure using one of the convenience methods
/// like `returns(_:)`, `succeeds(_:)`, `fails(_:)`.
///
/// ```swift
/// final class MockSomeAPI: SomeAPIProtocol {
///
///   let searchMock = MockFunc<(String, [String: String]?), SearchResponse>()
///   func search(query: String, attributes: [String: String]?, completion: @escaping (SearchResponse) -> Void) {
///	     searchMock.callAndReturn((query, attributes), completion: completion)
///   }
/// }
/// ```
public final class MockFunc<Input, Output>: MockFuncInvoking, WhenCalledConfigurable, @unchecked Sendable {

	// MARK: - Properties

	/// A result container that will be called to generate the mock's output.
	/// This is a required property to set up before using the mock function.
	private var result: ResultContainer<Input, Output>

	/// A callback that is triggered when the mocked function is called.
	private var didCall: (Input) -> Void = { _ in }

	/// A list of all arguments passed to the mocked function.
	public private(set) var invocations: [Input] = []

	/// A list of all completion closures called from the mocked function.
	public private(set) var completions: [CompletionContainer<Output>] = []

	/// When testing closure-based functions, this flag indicates if the completion closure should be triggered immediately (if set to true) or just put into `completions` if set to false.
	///
	/// Default value is true.
	public var callsCompletionImmediately = true

	/// The result of the mocked function
	public var output: Output {
		result(input)
	}

	/// The last completion closure
	public var completion: CompletionContainer<Output> {
		completions[count - 1]
	}

	// MARK: - Init

	/// Create an instance of mock.
	/// - Parameters:
	///		- function: in our setup the #function will return the name of the Mock as all the mocks will be instantiated during the allocation of the mocked entity.
	///		- line: line that will point to the exact place in file where this Mock was instantiated.
	public init(function: StaticString = #function, line: Int = #line) {
		result = ResultContainer<Input, Output> { _ in fatalError("You must provide a result handler before using MockFunc instantiated at line: \(line) of \(function)") }
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
	public func callAndReturn(_ input: Input) -> Output {
		call(with: input)
		return output
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
		completion: @escaping @isolated(any) (Output) -> Void
	) {
		call(with: input)
		let completionContainer = CompletionContainer(completion)
		completions.append(completionContainer)
		if callsCompletionImmediately {
			completionContainer(output)
		}
	}

	/// Get notified when a function is called. The function's input will be provided inside the closure.
	///
	///	- Note: This is a good place to put your `expectation.fulfill()` call if you need one.
	/// - Parameters:
	/// 	- closure: A callback that will be triggered when the mocked function is called.
	public func whenCalled(closure: @escaping (Input) -> Void) {
		didCall = closure
	}

	// MARK: - Private mock logic

	/// Triggering this function will append input to the list of invocations and trigger `didCall` callback.
	///
	///	- Parameters:
	/// 	- input: arguments of the mocked function.
	private func call(with input: Input) {
		invocations.append(input)
		didCall(input)
	}
}

// MARK: - Convenience

public extension MockFunc {

	/// Set the result of the mocked function.
	///
	/// How to use it:
	/// ```swift
	/// searchMock.returns(SearchResult(id: "1"))
	/// ```
	func returns(_ value: Output) {
		result = ResultContainer<Input, Output> { _ in value }
	}

	/// Set the result of the mocked function. For Void functions it's still necessary to provide the result, otherwise the mock is not considered configured.
	///
	/// If your function doesn't return any value, this is a shorthand function to set the mock up, because `result` must be set no matter what.
	///
	/// How to use it:
	/// ```swift
	/// searchMock.returns()
	/// ```
	func returns() where Output == Void {
		result = ResultContainer<Input, Output> { _ in () }
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
		result = ResultContainer<Input, Output> { _ in nil }
	}

	/// Set the successful result of the mocked function to the specified value.
	///
	/// If your function returns `Result<Output, Error>`,
	/// this is a shorthand for
	/// ```swift
	/// returns(.success(Output))
	/// ```
	///
	/// How to use it:
	/// ```swift
	/// searchMock.succeeds(SearchResult(id: "1"))
	/// ```
	func succeeds<T, Error>(_ value: T) where Output == Result<T, Error> {
		result = ResultContainer<Input, Output> { _ in .success(value) }
	}

	/// Set the successful result of the mocked function.  For Void functions it's still necessary to provide the result, otherwise the mock is not considered configured.
	///
	/// If your function returns `Result<Void, Error>`, this is a shorthand function to set the mock up.
	///
	/// How to use it:
	/// ```swift
	/// searchMock.succeeds()
	/// ```
	func succeeds<Error>() where Output == Result<Void, Error> {
		result = ResultContainer<Input, Output> { _ in .success(()) }
	}

	/// Set the result of the mocked function to the provided error.
	///
	/// If your function returns `Result<Output, Error>`,
	/// this is a shorthand for
	/// ```swift
	/// returns(.failure(Error))
	/// ```
	///
	/// How to use it:
	/// ```swift
	/// searchMock.fails(Error.testError)
	/// ```
	func fails<T, Error>(_ error: Error) where Output == Result<T, Error> {
		result = ResultContainer<Input, Output> { _ in .failure(error) }
	}
}

public extension MockFunc where Input == Void {
	/// A shorthand of `call(with: Input)` for functions without arguments.
	func call() {
		call(with: ())
	}

	/// A shorthand of `callAndReturn(with: Input) -> Output` for functions without arguments.
	func callAndReturn() -> Output {
		call(with: ())
		return output
	}
}
