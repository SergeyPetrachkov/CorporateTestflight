import MockFunc
import Testing

struct CompletionContainerTests {

	@Test
	func callAsFunction_shouldCallNonisolatedClosure() {
		let nonisolatedClosure: (Int) -> Void = { arg in
			#expect(arg == 42)
		}
		let sut = CompletionContainer(nonisolatedClosure)

		sut.callAsFunction(42)
	}

	@MainActor
	@Test
	func callAsFunction_shouldCallIsolatedClosure() {
		struct Arg {
			let bool: Bool
			let int: Int
		}
		let sample = Arg(bool: true, int: 42)
		let isolatedClosure: @MainActor (Arg) -> Void = { arg in
			#expect(arg.bool)
			#expect(arg.int == 42)
		}
		let sut = CompletionContainer(isolatedClosure)

		sut.callAsFunction(sample)
	}
}
