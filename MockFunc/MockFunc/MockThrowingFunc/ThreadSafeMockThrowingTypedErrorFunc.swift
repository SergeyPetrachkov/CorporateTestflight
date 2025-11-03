import Foundation

/// This is an actor that encapsulates Mock logic for any throwing async function that receives input of a certain type and produces output of a given type.
/// There is a separate object for throwing functions because otherwise if we used one universal object for all cases it would become less convenient to work with for non-throwing cases.
///
///	- Note: This mock is recommended to use when you are testing highly concurrent code. The state mutation will be controlled via actor's executor.
///
///
/// To start using mock, one needs to provide the `result` closure using one of the convenience methods
/// like `returns(_:)`, `throws(_:)`.
///
/// ```swift
/// final class MockSomeAPI: SomeAPIProtocol {
///
///   let lookupMock = ThreadSafeMockThrowingTypedErrorFunc<String, SearchResponse, APIError>()
///   func lookup(id: String) async throws(APIError) -> SearchResponse {
///	     try await lookupMock.callAndReturn(id)
///   }
/// }
/// ```
public actor ThreadSafeMockThrowingTypedErrorFunc<Input, Output, ErrorType: Swift.Error>: AsyncMockFuncInvoking, WhenCalledIsolatedConfigurable {

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
	///
	/// The mock is initialized with a default result container that throws a `fatalError`
	/// if called before being properly configured. This ensures that unconfigured mocks
	/// fail fast with clear error messages indicating where the mock was created.
	///
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
	public func callAndReturn(_ input: sending Input) throws(ErrorType) -> Output {
		invocations.append(input)
		didCall(input)
		return try output
	}

	/// Get notified when a function is called. The function's input will be provided inside the closure.
	///
	///	- Note: This is a good place to put your `expectation.fulfill()` call if you need one.
	/// - Parameters:
	/// 	- closure: A callback that will be triggered when the mocked function is called.
	public func whenCalled(closure: sending @escaping (Input) -> Void) {
		didCall = closure
	}
}

// MARK: - Convenience

public extension ThreadSafeMockThrowingTypedErrorFunc {

	/// Set the result of the mocked function.
	///
	/// How to use it:
	/// ```swift
	/// searchMock.returns(SearchResult(id: "1"))
	/// ```
	///
	/// - Parameter value: The value to return when the mock is called
	func returns(_ value: Output) {
		result = ResultContainer { _ in value }
	}

	/// Set the result of the mocked function for Void return types.
	///
	/// For Void functions it's still necessary to provide the result container, 
	/// otherwise the mock is not considered configured and will trigger the fatal error.
	/// This convenience method sets up the container to return `()`.
	///
	/// How to use it:
	/// ```swift
	/// searchMock.returns()
	/// ```
	func returns() where Output == Void {
		result = ResultContainer { _ in () }
	}

	/// Set the result of the mocked function to `nil` for optional return types.
	///
	/// If your function returns an optional, and you want to mock nil, this is a 
	/// shorthand function to set the mock up with a container that returns `nil`.
	///
	/// How to use it:
	/// ```swift
	/// optionalSearchMock.returnsNil()
	/// ```
	func returnsNil<T>() where Output == Optional<T> {
		result = ResultContainer { _ in nil }
	}

	/// Set the error that must be thrown instead of returning a result.
	///
	/// This creates a `ThrowingResultContainer` that always throws the specified error
	/// when called, regardless of the input. The error type must match the `ErrorType`
	/// generic parameter of the mock.
	///
	/// How to use it:
	/// ```swift
	/// searchMock.throws(APIError.networkFailure)
	/// ```
	///
	/// - Parameter error: The error to throw when the mock is called
	func `throws`(_ error: ErrorType) {
		result = ResultContainer { _ throws(ErrorType) in
			throw error
		}
	}
}
