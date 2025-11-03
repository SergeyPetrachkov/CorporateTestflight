import Foundation

/// This is a class that encapsulates Mock logic for any throwing non-async function that receives input of a certain type and produces output of a given type.
/// There is a separate object for throwing functions because otherwise if we used one universal object for all cases it would become less convenient to work with for non-throwing cases.
///
///	- Note: This mock can be used for async functions, but it's important to understand that the Mock class is not thread-safe and is only safe to use outside of highly concurrent contexts. For concurrent scenarios, use `ThreadSafeMockThrowingTypedErrorFunc` instead.
///
/// To start using mock, one needs to provide the `result` closure using one of the convenience methods
/// like `returns(_:)`, `throws(_:)`.
///
/// There are two ways to use it: by manually specifying types for the mock or by using convenience function `mock` that will make compiler infer the type.
/// Sometimes (when dealing with closures) latter approach won't work, so it's recommended to use former.
/// ```swift
/// final class MockSomeAPI: SomeAPIProtocol {
///   let searchTypedThrowsMock = MockThrowingTypedErrorFunc<String, SearchResponse, SearchError>()
///   func search(query: String) throws(SearchError) -> SearchResponse {
///	     try searchTypedThrowsMock.callAndReturn(query)
///   }
///
///   let asyncLookupMock = MockThrowingTypedErrorFunc<String, SearchResponse, APIError>()
///   func asyncLookup(id: String) async throws(APIError) -> SearchResponse {
///	     try asyncLookupMock.callAndReturn(id)
///   }
/// }
/// ```
public final class MockThrowingTypedErrorFunc<Input, Output, ErrorType: Swift.Error>: MockFuncInvoking, WhenCalledConfigurable, @unchecked Sendable {

	public typealias ResultContainer = ThrowingResultContainer<Input, ErrorType, Output>

	// MARK: - Properties

	/// A result container that will be called to generate the mock's output.
	/// This is a required property to set up before using the mock function.
	private var result: ResultContainer

	/// A callback that is triggered when the mocked function is called.
	private var didCall: (Input) -> Void = { _ in }

	/// A list of all arguments passed to the mocked function.
	public private(set) var invocations: [Input] = []

	/// The result of the mocked function.
	///
	/// This computed property calls the result container with the provided input,
	/// effectively executing the configured mock behavior.
	public var output: Output {
		get throws(ErrorType) {
			try result(input)
		}
	}

	// MARK: - Init

	/// Create an instance of mock.
	/// - Parameters:
	///		- function: in our setup the #function will return the name of the Mock as all the mocks will be instantiated during the allocation of the mocked entity.
	///		- line: line that will point to the exact place in file where this Mock was instantiated.
	public init(function: StaticString = #function, line: Int = #line) {
		result = ResultContainer { _ in fatalError("You must provide a result handler before using MockFunc instantiated at line: \(line) of \(function)") }
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
	public func callAndReturn(_ input: Input) throws(ErrorType) -> Output {
		invocations.append(input)
		didCall(input)
		return try output
	}

	/// Get notified when a function is called. The function's input will be provided inside the closure.
	///
	///	- Note: This is a good place to put your `expectation.fulfill()` call if you need one.
	/// - Parameters:
	/// 	- closure: A callback that will be triggered when the mocked function is called.
	public func whenCalled(closure: @escaping (Input) -> Void) {
		didCall = closure
	}
}

// MARK: - Convenience

public extension MockThrowingTypedErrorFunc {

	/// Set the result of the mocked function.
	///
	/// How to use it:
	/// ```swift
	/// searchMock.returns(SearchResult(id: "1"))
	/// ```
	func returns(_ value: Output) {
		result = ResultContainer { _ in value }
	}

	/// Set the result of the mocked function. For Void functions it's still necessary to provide the result, otherwise the mock is not considered configured.
	///
	/// How to use it:
	/// ```swift
	/// searchMock.returns()
	/// ```
	func returns() where Output == Void {
		result = ResultContainer { _ in () }
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
		result = ResultContainer { _ in nil }
	}

	/// Set the error that must be thrown instead of the result of the mocked function.
	///
	/// How to use it:
	/// ```swift
	/// searchMock.throws(Error.testError)
	/// ```
	func `throws`(_ error: ErrorType) {
		result = ResultContainer { _ throws(ErrorType) in
			throw error
		}
	}
}
