import XCTest
import SimpleDI

final class ContainerTests: XCTestCase {

	func testRegisterAndResolveService() {
		let container = Container()

		container.register(String.self) { () -> String in "TestString" }

		let resolvedString: String? = container.resolve(String.self)

		XCTAssertEqual(resolvedString, "TestString")
	}

	func testRegisterAndResolveServiceWithArgument() {
		let container = Container()

		container.register(Int.self) { (arg: String) in
			return arg.count
		}

		let resolvedInt: Int? = container.resolve(Int.self, argument: "Test")

		XCTAssertEqual(resolvedInt, 4)
	}

	func testResolveUnregisteredService() {
		let container = Container()

		let resolvedString: String? = container.resolve(String.self)

		XCTAssertNil(resolvedString)
	}

	func testResolveServiceWithInvalidArgumentType() {
//		let container = Container()
//
//		container.register(Int.self) { (arg: String) in
//			return arg.count
//		}
//
//		let resolvedInt: Int? = container.resolve(Int.self, argument: 123)
//
//		XCTAssertNil(resolvedInt)
	}

	func testThreadSafety() {
		let container = Container()
		let expectation = self.expectation(description: "Thread safety test")
		let iterations = 1000

		DispatchQueue.concurrentPerform(iterations: iterations) { index in
			container.register(String.self) { "TestString\(index)" }
			let resolvedString: String? = container.resolve(String.self)
			XCTAssertNotNil(resolvedString)
		}

		expectation.fulfill()
		wait(for: [expectation], timeout: 5.0)
	}
}

