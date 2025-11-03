import Foundation

/// Property wrapper that mocks a property.
///
/// How to use it
/// ```swift
/// protocol MyProtocol {
///   var myProperty: Int { get set }
/// }
///
/// final class MockMyProtocol: MyProtocol {
///   @Mock
///   var myProperty: Int
/// }
/// ```
/// How to set up initial Mock value:
/// ```swift
/// mock.$myProperty.returns(1)
/// ```
/// How to get notified when a new value is assigned to the mock
/// ```swift
/// mock.$myProperty.whenSet { result in
///   // the latest value will be here, and we can also fulfill expectations if any
/// }
/// ```
/// How to check the last assigned value
/// ```swift
/// XCTAssertEqual(mock.$myProperty.assignments.last, expectedResult)
/// ```
@propertyWrapper
public final class Mock<T> {

	public var projectedValue = MockVar<T>()
	public var wrappedValue: T {
		get {
			projectedValue.getCount += 1
			return projectedValue.return()
		}
		set {
			projectedValue.assign(newValue)
			projectedValue.didSet?(newValue)
		}
	}

	public init() {
	}
}

/// A class that encapsulates the logic of mocking any property. It is supposed to be used only in combination with `Mock<T>` property wrapper.
public final class MockVar<T> {

	// MARK: - Value Definition
	private enum Value {
		case empty
		case one(T)
		case many([T])

		mutating func set(_ value: T) {
			self = .one(value)
		}

		mutating func append(_ value: T) {
			switch self {
			case .empty:
				self = .many([value])
			case .one(let currentValue):
				self = .many([currentValue, value])
			case .many(let values):
				self = .many(values + [value])
			}
		}

		mutating func `return`() -> T {
			switch self {
			case .empty:
				fatalError("Return value not set")
			case .one(let value):
				return value
			case .many(let values) where values.isEmpty:
				fatalError("No return values left")
			case .many(let values):
				let value = values[0]
				self = .many(Array(values.dropFirst()))
				return value
			}
		}
	}

	// MARK: - Properties

	/// Returns how many times the setter was called
	public var setCount: Int {
		assignments.count
	}
	/// Returns how many times the getter was called
	public fileprivate(set) var getCount = 0

	/// An array of all values that were assigned to the mocked property.
	public private(set) var assignments = [T]()

	/// A callback that should triggered when a new value gets assigned to the mocked property.
	fileprivate(set) var didSet: ((T) -> Void)?

	/// Value that should be returned from the mocked property.
	///
	/// The default value is `Value.empty` which will result in a fatal error as with the rest mocks as, in this case, the mock is considered not set up properly.
	private var returnValue = Value.empty

	// MARK: Class interface

	/// Add a newly assigned value to the `assignments`
	func assign(_ value: T) {
		assignments.append(value)
	}

	/// Read and return the first enqueued value.
	/// This value will be removed from the list afterwards.
	///
	/// This function accesses the internal `Value.return()` function.
	func `return`() -> T {
		returnValue.return()
	}
}

// MARK: - Convenience

public extension MockVar {

	/// Set up the mock to return the specified value.
	@discardableResult
	func returns(_ value: T) -> Self {
		returnValue.set(value)
		return self
	}

	/// Use this function to chain several return values. Values will be stored and retrieved in the order they have been added.
	@discardableResult
	func thenReturns(_ value: T) -> Self {
		returnValue.append(value)
		return self
	}

	/// Set a callback for the moment when a new value gets assigned to the property.
	@discardableResult
	func whenSet(_ callback: @escaping (T) -> Void) -> Self {
		didSet = callback
		return self
	}
}
