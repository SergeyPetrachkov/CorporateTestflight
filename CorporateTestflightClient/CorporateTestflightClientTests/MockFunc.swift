import Foundation

final class MockFunc<Input, Output> {

    typealias Pipeline = (Input) -> Output

    var parameters: [Input] = []
    var completions: [(Output) -> Void] = []
    var result: Pipeline = { _ in fatalError("Not implemented") }
    var didCall: (Input) -> Void = { _ in }
    var callsCompletionImmediately = true

    init() {}

    init(result: @escaping Pipeline) {
        self.result = result
    }

    var count: Int {
        parameters.count
    }

    var called: Bool {
        !parameters.isEmpty
    }

    var output: Output {
        result(input)
    }

    var input: Input {
        parameters[count - 1]
    }

    var completion: (Output) -> Void {
        completions[count - 1]
    }

    static func mock(for function: (Input) throws -> Output) -> MockFunc {
        return MockFunc()
    }

    func call(with input: Input) {
        parameters.append(input)
        didCall(input)
    }

    func callAndReturn(_ input: Input) -> Output {
        call(with: input)
        return output
    }

    func callAndReturn(
        _ input: Input,
        completion: @escaping (Output) -> Void
    ) {
        call(with: input)
        storeCompletionAndCallIfNeeded(completion, output: output)
    }

    private func storeCompletionAndCallIfNeeded(
        _ completion: @escaping (Output) -> Void,
        output: @autoclosure () -> Output
    ) {
        completions.append(completion)
        if callsCompletionImmediately {
            completion(output())
        }
    }
}

// MARK: Syntactic Sugar

extension MockFunc {
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
}

extension MockFunc where Input == Void {
    func call() {
        call(with: ())
    }

    func callAndReturn() -> Output {
        call(with: ())
        return output
    }

    func callAndReturn(
        completion: @escaping (Output) -> Void
    ) {
        call(with: ())
        storeCompletionAndCallIfNeeded(completion, output: output)
    }
}

extension MockFunc where Output == Void {
    func call(
        _ input: Input,
        completion: @escaping () -> Void
    ) {
        call(with: input)
        storeCompletionAndCallIfNeeded(completion, output: ())
    }
}
