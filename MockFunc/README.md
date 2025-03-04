# MockFunc

MockFunc framework is useful for unit testing, allowing developers to simulate the behavior of complex systems and isolate components for testing.
MockFunc is strict Swift Concurrency and Swift 6 ready.

## Overview

The provided utilities include:

**Protocols**:
- `MockFuncInvoking`
- `AsyncMockFuncInvoking`

**Types**:
- `MockFunc`
- `MockThrowingFunc`
- `ThreadSafeMockFunc`
- `ThreadSafeMockThrowingFunc`
- `Mock`
- `MockVar`

These tools provide mechanisms for tracking and controlling function calls, arguments, and return values or errors.

## Protocols

### `MockFuncInvoking`

A protocol for mocking functions with basic functionality:
**Associated Types**:
- `Input`: The type of the input arguments for the mocked function.
**Properties**:
- `invocations`: An array storing all the inputs passed to the mocked function.

### `AsyncMockFuncInvoking`

An actor protocol extending `MockFuncInvoking` with syntax sugar for asynchronous operations:
- Similar functionality to `MockFuncInvoking` but designed for use with Swift's concurrency features.

## Implementing types

### `MockFunc`

A class for mocking non-throwing functions. You can test **both** sync and async functions with that, but keep in mind that this mock is **not** thread-safe.
**Generics**:
- `Input`: Type of the function's input.
- `Output`: Type of the function's output.
**Properties**:
- `didCall`: Callback executed whenever the function is called.
- `invocations`: Stores all inputs received by the function.
- `completions`: Stores all completion closures called by the function.
- `result`: Closure to provide the function's result.
**Methods**:
- `callAndReturn(_:)`: Call the mocked function and return a result.
- `callAndReturn(_:completion:)`: For closure-based functions, call the function and handle the completion.
- `whenCalled(closure:)`: Register a callback for when the function is called.

### `MockThrowingFunc`

Similar to `MockFunc`, but for functions that can throw errors:
**Methods**:
- `callAndReturn(_:) throws`: Calls the function and returns a result or throws an error.
- `callAndReturn(_:completion:) throws`: For closure-based functions, handles errors.

### `ThreadSafeMockFunc`

An actor-based mock for non-throwing, async functions:
- Designed for high concurrency scenarios, using Swift actors to manage state changes safely.
**Methods**:
- Similar to `MockFunc`, but leveraging Swift's actor model for concurrency safety.

### `ThreadSafeMockThrowingFunc`

An actor-based mock for throwing async functions:
- Combines the functionality of `MockThrowingFunc` with the concurrency safety of Swift actors.

### `Mock`

A property wrapper for mocking properties:
**Generics**:
- `T`: Type of the property being mocked.
**Usage**:
- Use `@Mock` to declare mock properties within a class or struct.
- Use `$propertyName.returns(value)` to set return values.
- Use `$propertyName.whenSet(callback:)` to register a callback when the property is set.

### `MockVar`

Encapsulates the logic for mocking properties:
**Properties**:
- `assignments`: Stores all values assigned to the property.
- `didSet`: Callback for when a new value is assigned.
**Methods**:
- `returns(_)`: Sets the return value for the mock.
- `thenReturns(_)`: Chains multiple return values.
- `whenSet(_)`: Sets a callback for when the property is assigned a new value.

## Usage Examples

### Mocking a Function

Non thread-safe Mock for closure-based API:
```swift
final class MockSomeAPI: SomeAPIProtocol {
	let searchMock = MockFunc<(String, [String: String]?), SearchResponse>()

	func search(query: String, attributes: [String: String]?, completion: @escaping (SearchResponse) -> Void) {
		searchMock.callAndReturn((query, attributes), completion: completion)
	}
}
```

Non thread-safe Mock for async API:
```swift
final class MockSomeAPI: SomeAPIProtocol {
	let searchMock = MockFunc<(String, [String: String]?), SearchResponse>()
	func search(query: String, attributes: [String: String]?) async -> SearchResponse {
		searchMock.callAndReturn((query, attributes))
	}
}
```

Thread-safe Mock for async API:
```swift
final class MockSomeAPI: SomeAPIProtocol {
	let searchMock = ThreadSafeMockFunc<(String, [String: String]?), SearchResponse>()
	func search(query: String, attributes: [String: String]?) async -> SearchResponse {
		await searchMock.callAndReturn((query, attributes))
	}
}
```

### Mocking a Property

```swift
final class MockMyProtocol: MyProtocol {
	@Mock var myProperty: Int
}

func test_Your_Stuff() {
	let sut = environemnt.makeSUT()

	// Setup initial mock value
	environemnt.mock.$myProperty.returns(1)

	let expectatation =  expectation(description: "Async expectation")

	// Get notified when a new value is assigned
	environemnt.mock.$myProperty.whenSet { newValue in
		print("New value set: \(newValue)")
		expectation.fulfill()
	}
	
	sut.doSomeStuff()
	waitForExpectations(timeout: 1.0)

	// Check the last assigned value
	XCTAssertEqual(mock.$myProperty.assignments.last, expectedValue)
}
```

These utilities provide a flexible framework for creating mock objects, allowing developers to test code in isolation without relying on external systems or complex dependencies.
