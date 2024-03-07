import Foundation

public actor AsyncThrowingMockFunc<Input, Output> {

    public typealias Pipeline = (Input) throws -> Output

    private var parameters: [Input] = []
    private var completions: [(Output) -> Void] = []
    private var result: Pipeline = { _ in fatalError("Not implemented") }
    private var didCall: (Input) -> Void = { _ in }

    public init() {}

    public init(result: @escaping Pipeline) {
        self.result = result
    }

    public var count: Int {
        parameters.count
    }

    public var called: Bool {
        !parameters.isEmpty
    }

    public var output: Output {
        get async throws {
            try result(input)
        }
    }

    public var input: Input {
        parameters[count - 1]
    }

    public var completion: (Output) -> Void {
        completions[count - 1]
    }

    public func call(with input: Input) {
        parameters.append(input)
        didCall(input)
    }
}

// MARK: Syntactic Sugar

extension AsyncThrowingMockFunc {

    /// Just some sugar to make it easier to use the mock without explicitly specifying types
    public static func mock(for function: (Input) async throws -> Output) -> AsyncThrowingMockFunc {
        AsyncThrowingMockFunc()
    }

    func returns(_ value: Output) {
        result = { _ in value }
    }

    func returns() where Output == Void {
        result = { _ in () }
    }

    func returnsNil<T>() where Output == Optional<T> {
        result = { _ in nil }
    }

    func succeeds<T, Error>(_ value: T) where Output == Result<T, Error> {
        result = { _ in .success(value) }
    }

    func succeeds<Error>() where Output == Result<Void, Error> {
        result = { _ in .success(()) }
    }

    func fails<T, Error>(_ error: Error) where Output == Result<T, Error> {
        result = { _ in .failure(error) }
    }

    func `throws`(_ error: Error) {
        result = { _ in throw error }
    }
}
