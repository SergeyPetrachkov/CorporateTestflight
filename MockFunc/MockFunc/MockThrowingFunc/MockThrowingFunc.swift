/// A convenience typealias that can be used for mocking functions that throw without specifying the error type. Not thread-safe.
public typealias MockThrowingFunc<Input, Output> = MockThrowingTypedErrorFunc<Input, Output, any Error>
