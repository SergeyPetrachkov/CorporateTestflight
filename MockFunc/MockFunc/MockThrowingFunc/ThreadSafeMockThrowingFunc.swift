/// A convenience typealias that can be used for mocking functions that throw without specifying the error type. Thread-safe via Actors.
public typealias ThreadSafeMockThrowingFunc<Input, Output> = ThreadSafeMockThrowingTypedErrorFunc<Input, Output, any Error>
