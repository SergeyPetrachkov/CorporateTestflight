import MockFunc
import Testing
import CorporateTestflightDomain
import Foundation
@testable import VersionsBrowser

// Plan: 7.1 Store tests
// Parametric tests
// Cancellation
// Single interface function testing

@Suite("Versions List Store")
@MainActor
struct VersionsListStoreTests {

	@MainActor
	struct Environment {
		let projectID = 1
		let usecase = MockFetchProjectAndVersionsUsecase()
		let mapper = MockRowMapper()
		var output: @MainActor (VersionList.Environment.Output) -> Void = { _ in }

		func makeSUT() -> VersionsListStore {
			VersionsListStore(
				initialState:
					VersionList
					.State(),
				environment:
					VersionsListStore
					.Environment(
						project: projectID,
						usecase: usecase,
						mapper: mapper,
						debounceMilliseconds: 0,
						output: output
					)
			)
		}
	}

	// start, refresh(fromScratch:)
	@Test(
		"Start and Refresh Happy path"
	)
	func sendResultsInLoadedState() async {

	}

	@Test(
		"Start and Refresh Unhappy path"
	)
	func sendFailureResultsInFailedState() async {
		let env = Environment()
		let testError = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ha-ha!"])
		env.usecase.executeMock.throws(testError)
		let sut = env.makeSUT()

	}

	@Test(
		"Search Happy Path"
	)
	func searchHappyPath() async {

	}

	@Test(
		"Search No Project Loaded"
	)
	func searchUnhappyPath() async {

	}

	@Test
	func tapVersionHappyPath() async {

	}

	@Test
	func tapNonExistantVersion() async {

	}

	@Test
	func tapQR() async {

	}

	@Test
	func taskCancellation() async {

	}
}
