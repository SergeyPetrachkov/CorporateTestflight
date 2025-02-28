import XCTest
@testable import SimpleDI

final class ContainerTests: XCTestCase {

	func testRegisterAndResolveService() {
		let container = Container()

		container.register(String.self) { (_, resolver) in "TestString" }

		let resolvedString: String? = container.resolve(String.self)

		XCTAssertEqual(resolvedString, "TestString")
	}

	func testRegisterAndResolveServiceWithArgument() {
		let container = Container()

		container.register(Int.self) { (arg: String, resolver) in
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

	func testRegisterAndResolveSingletonService() {

		class SUT {
			let property: String
			init(property: String) {
				self.property = property
			}
		}
		let container = Container()

		container.registerSingleton(SUT.self) { (_, resolver) in SUT(property: "SingletonString") }

		let resolvedSUT1: SUT? = container.resolve(SUT.self)
		let resolvedSUT2: SUT? = container.resolve(SUT.self)

		XCTAssertEqual(resolvedSUT1?.property, "SingletonString")
		XCTAssertEqual(resolvedSUT2?.property, "SingletonString")
		XCTAssertTrue(resolvedSUT1 === resolvedSUT2)
	}

	func testRegisterAndResolveSingletonServiceWithArgument() {
		class SUT {
			let property: String
			init(property: String) {
				self.property = property
			}
		}
		let container = Container()

		container.registerSingleton(SUT.self) { (argument, resolver) in SUT(property: argument) }

		let resolvedSUT1: SUT? = container.resolve(SUT.self, argument: "SingletonString")
		let resolvedSUT2: SUT? = container.resolve(SUT.self, argument: "SomethingElse")

		XCTAssertEqual(resolvedSUT1?.property, "SingletonString")
		XCTAssertEqual(resolvedSUT2?.property, "SingletonString")
		XCTAssertTrue(resolvedSUT1 === resolvedSUT2)
	}

	func testThreadSafety() {
		let container = Container()
		let expectation = self.expectation(description: "Thread safety test")
		let iterations = 1000

		DispatchQueue.concurrentPerform(iterations: iterations) { index in
			container.register(String.self) { (_, resolver) in "TestString\(index)" }
			let resolvedString: String? = container.resolve(String.self)
			XCTAssertNotNil(resolvedString)
		}

		expectation.fulfill()
		wait(for: [expectation], timeout: 5.0)
	}
}

