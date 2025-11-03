/// A container that wraps a throwing closure with typed error handling.
///
/// This struct provides a clean abstraction around closures that can throw specific error types,
/// with optimized call-site performance through inlining. The `callAsFunction` implementation
/// allows instances to be called directly like functions.
///
/// - Note: The `@inline(__always)` attribute ensures zero-overhead abstraction by eliminating
///   the wrapper function call at compile time.
public struct ThrowingResultContainer<Input, ErrorType: Swift.Error, Output> {

	/// The underlying closure that performs the actual work.
	let closure: (Input) throws(ErrorType) -> Output

	/// Calls the underlying closure with the provided input.
	///
	/// - Parameter input: The input value to pass to the underlying closure
	/// - Returns: The result of calling the underlying closure
	/// - Throws: Any error of type `ErrorType` that the underlying closure throws
	@inline(__always)
	func callAsFunction(_ input: Input) throws(ErrorType) -> Output {
		try closure(input)
	}
}

/// A container that wraps a non-throwing closure for consistent API design.
///
/// This struct mirrors `ThrowingResultContainer` but for closures that don't throw errors.
/// It provides the same performance characteristics and API surface, enabling consistent
/// usage patterns across both throwing and non-throwing mock scenarios.
///
/// - Note: The `@inline(__always)` attribute ensures zero-overhead abstraction.
public struct ResultContainer<Input, Output> {

	/// The underlying closure that performs the actual work.
	let closure: (Input) -> Output

	/// Calls the underlying closure with the provided input.
	///
	/// - Parameter input: The input value to pass to the underlying closure
	/// - Returns: The result of calling the underlying closure
	@inline(__always)
	func callAsFunction(_ input: Input) -> Output {
		closure(input)
	}
}
