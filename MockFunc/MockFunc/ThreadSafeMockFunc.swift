import Foundation

/// This is an actor that encapsulates Mock logic for any non-throwing async function that receives input of a certain type and produces output of a given type.
///
///	- Note: This mock is recommended to use when you are testing highly concurrent code. The state mutation will be controlled via actors executor.
///
/// To start using mock, one needs to provide the `result` closure.
///
/// ```swift
/// final class MockSomeAPI: SomeAPIProtocol {
///
///   let lookupMock = MockFunc<String, Result<SearchResponse, Error>>()
///   func lookup(id: String) async -> Result<SearchResponse, Error> {
///	     lookupMock.callAndReturn(id)
///   }
/// }
/// ```
public actor ThreadSafeMockFunc<Input, Output>: AsyncMockFuncInvoking {

	// MARK: - Properties
	/// A callback that is triggered when the mocked function is called.
	private var didCall: (Input) -> Void = { _ in }

	/// A list of all arguments passed to the mocked function.
	public private(set) var invocations: [Input] = []

	/// A way to inject the result. This is a required property to set up before using the mock function.
	public private(set) var result: (Input) -> Output

	/// The result of the mocked function
	public var output: Output {
		result(input)
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
	public func callAndReturn(_ input: Input) -> Output {
		call(with: input)
		return output
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

public extension ThreadSafeMockFunc {

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
	/// If your function doesn't return any value, this is a shorthand function to set the mock up, because `result` must be set no matter what.
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
	func returnsNil<T>() where Output == Optional<T> {
		result = { _ in nil }
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
		result = { _ in .success(value) }
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
		result = { _ in .success(()) }
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
		result = { _ in .failure(error) }
	}
}

public extension ThreadSafeMockFunc where Input == Void {
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
