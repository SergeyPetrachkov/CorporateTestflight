import Foundation

/// This is an actor that encapsulates Mock logic for any throwing async function that receives input of a certain type and produces output of a given type.
/// There is a separate object for throwing functions because otherwise if we used one universal object for all cases it would become less convenient to work with for non-throwing cases.
///
///	- Note: This mock is recommended to use when you are testing highly concurrent code. The state mutation will be controlled via actors executor.
///
/// To start using mock, one needs to provide the `result` closure.
///
/// ```swift
/// final class MockSomeAPI: SomeAPIProtocol {
///
///   let lookupMock = MockThrowingFunc<String, SearchResponse>()
///   func lookup(id: String) async throws -> SearchResponse {
///	     try lookupMock.callAndReturn(id)
///   }
/// }
/// ```
public actor ThreadSafeMockThrowingFunc<Input, Output>: AsyncMockFuncInvoking {

	// MARK: - Properties
	/// A callback that is triggered when the mocked function is called.
	private var didCall: (Input) throws -> Void = { _ in }

	/// A list of all arguments passed to the mocked function.
	public private(set) var invocations: [Input] = []

	/// A way to inject the result. This is a required property to set up before using the mock function.
	public private(set) var result: (Input) throws -> Output

	/// The result of the mocked function
	public var output: Output {
		get throws {
			try result(input)
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

	/// Get notified when a function is called. The function's input will be provided inside the closure.
	///
	///	- Note: This is a good place to put your `expectation.fulfill()` call if you need one.
	/// - Parameters:
	/// 	- closure: A callback that will be triggered when the mocked function is called.
	public func whenCalled(closure: @escaping (Input) throws -> Void) {
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
}

// MARK: - Convenience

public extension ThreadSafeMockThrowingFunc {

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
	func returnsNil<T>() where Output == Optional<T> {
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
