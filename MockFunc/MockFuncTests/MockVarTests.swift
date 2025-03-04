import MockFunc
import Testing

@Suite
struct MockVarTests {

	protocol TestProtocol {
		var intValue: Int { get set }
	}

	final class MockTestProtocol: TestProtocol {
		@Mock var intValue: Int
	}

	@Test
	func returnValueReturnsTheExpectedValue() {
		let sut = MockTestProtocol()
		let expectedValue = 42
		sut.$intValue.returns(expectedValue)
		#expect(sut.intValue == expectedValue)
	}

	@Test
	func assignmentsTracking() {
		let mock = MockTestProtocol()
		mock.intValue = 10
		mock.intValue = 20

		#expect(mock.$intValue.assignments == [10, 20])
	}

	@Test
	func multipleReturnValues() {
		let sut = MockTestProtocol()
		sut
			.$intValue
			.thenReturns(1)
			.thenReturns(2)
			.thenReturns(3)
			.thenReturns(4)

		#expect(sut.intValue == 1)
		#expect(sut.intValue == 2)
		#expect(sut.intValue == 3)
		#expect(sut.intValue == 4)
	}

	@Test
	func emptyToManyTransition() {
		let sut = MockTestProtocol()
		sut.$intValue.returns(1)
		sut.$intValue.thenReturns(2)

		#expect(sut.intValue == 1)
		#expect(sut.intValue == 2)
	}

	@Test
	func setCallbackGetsCalled() async {
		let sut = MockTestProtocol()
		sut.$intValue.returns(1)
		let stream = AsyncStream { continuation in
			sut.$intValue.whenSet { _ in
				continuation.yield()
			}
			sut.intValue = 2
		}
		var iterator = stream.makeAsyncIterator()
		await iterator.next()
		#expect(sut.$intValue.assignments.last == 2)
	}
}
