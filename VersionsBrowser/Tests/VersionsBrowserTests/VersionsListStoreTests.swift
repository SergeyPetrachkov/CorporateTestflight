import MockFunc
import Testing
import CorporateTestflightDomain
import Foundation
@testable import VersionsBrowser

@Suite("Versions List Store")
@MainActor
struct VersionsListStoreTests {

	@Test(
		"Start and Refresh Happy path",
		.happyPathEnvironment,
		arguments: [
			VersionList.Action.start,
			VersionList.Action.refresh(fromScratch: true),
			VersionList.Action.refresh(fromScratch: false)
		]
	)
	func sendResultsInLoadedState(action: VersionList.Action) async {
		let env = Environment.current
		let sut = env.makeSUT()

		await sut.send(action)

		#expect(env.usecase.executeMock.input == env.expectedProject.id)
		#expect(env.usecase.executeMock.calledOnce)
		#expect(env.mapper.mapMock.calledOnce)
		#expect(env.mapper.mapMock.input == env.expectedVersions)
		#expect(sut.state.seachTerm == "")
		#expect(sut.state.contentState == .loaded(VersionList.State.Content(projectTitle: "Name", versions: env.expectedRows)))
	}

	@Test(
		"Start and Refresh Unhappy path",
		.unhappyPathEnvironment,
		arguments: [
			VersionList.Action.start,
			VersionList.Action.refresh(fromScratch: true),
			VersionList.Action.refresh(fromScratch: false)
		]
	)
	func sendFailureResultsInFailedState(action: VersionList.Action) async {
		let env = Environment.current
		let sut = env.makeSUT()

		await sut.send(.start)

		#expect(env.usecase.executeMock.input == env.expectedProject.id)
		#expect(env.usecase.executeMock.calledOnce)
		#expect(!env.mapper.mapMock.called)
		#expect(sut.state.seachTerm == "")
		#expect(sut.state.contentState == .failed(VersionList.State.ErrorState(localizedDescription: "Ha-ha!")))
	}

	@Test(
		"Search Happy Path",
		.happyPathEnvironment,
		arguments: [
			VersionList.Action.search,
			VersionList.Action.debouncedSearch
		]
	)
	func searchHappyPath(action: VersionList.Action) async {
		let env = Environment.current
		let sut = env.makeSUT()
		sut.state.seachTerm = "Key"

		await sut.send(.start)  // to load the project
		await sut.send(action)

		#expect(env.usecase.executeMock.input == env.expectedProject.id)
		#expect(env.usecase.executeMock.calledOnce)
		#expect(env.mapper.mapMock.count == 2)
		#expect(env.mapper.mapMock.input == env.expectedVersions)
		#expect(sut.state.seachTerm == "Key")
		#expect(sut.state.contentState == .loaded(VersionList.State.Content(projectTitle: "Name", versions: env.expectedRows)))
	}

	@Test(
		"Search No Project Loaded",
		arguments: [
			VersionList.Action.search,
			VersionList.Action.debouncedSearch
		]
	)
	func searchUnhappyPath(action: VersionList.Action) async {
		let env = Environment()
		let sut = env.makeSUT()
		sut.state.seachTerm = "Key"

		await sut.send(action)

		#expect(env.mapper.mapMock.count == 0)
		#expect(sut.state.seachTerm == "Key")
		#expect(sut.state.contentState == .failed(.init(localizedDescription: "No project is loaded. Try refreshing.")))
	}

	@Test(.happyPathEnvironment)
	func tapVersionHappyPath() async {
		var env = Environment.current
		var outputCalledCorrectly = false
		env.output = { argument in
			switch argument {
			case .qrRequested:
				outputCalledCorrectly = false
			case .selectedVersion(let version):
				outputCalledCorrectly = version.id == env.versionUUID
			}
		}
		let sut = env.makeSUT()

		await sut.send(.start)  // to load versions
		await sut.send(.tapItem(.init(id: env.versionUUID, title: "", subtitle: "")))

		#expect(outputCalledCorrectly)
	}

	@Test
	func tapNonExistantVersion() async {
		var env = Environment()

		var outputHandledCorrectly = true
		env.output = { _ in
			outputHandledCorrectly = false
		}
		let sut = env.makeSUT()

		await sut.send(.tapItem(.init(id: UUID(), title: "", subtitle: "")))

		#expect(outputHandledCorrectly)
	}

	@Test
	func tapQR() async {
		var env = Environment()

		var outputCalledCorrectly = false
		env.output = { argument in
			switch argument {
			case .qrRequested:
				outputCalledCorrectly = true
			case .selectedVersion:
				outputCalledCorrectly = false
			}
		}
		let sut = env.makeSUT()

		await sut.send(.tapQR)

		#expect(outputCalledCorrectly)
	}

	@Test(.happyPathEnvironment)
	func taskCancellation() async {
		let env = Environment.current
		let sut = env.makeSUT()

		let task = Task { await sut.send(.start) }
		task.cancel()

		#expect(sut.state.contentState == .loading)
	}
}

@MainActor
private struct Environment {
	let usecase = MockFetchProjectAndVersionsUsecase()
	let mapper = MockRowMapper()
	var output: @MainActor (VersionList.Environment.Output) -> Void = { _ in }

	let expectedProject: Project
	let expectedVersions: [Version]
	let expectedRows: [VersionList.RowState]
	let versionUUID: UUID

	init(
		expectedProject: Project = Project(id: 1, name: "Name"),
		expectedVersions: [Version] = [],
		expectedRows: [VersionList.RowState] = [],
		versionUUID: UUID = UUID()
	) {
		self.expectedProject = expectedProject
		self.expectedVersions = expectedVersions
		self.expectedRows = expectedRows
		self.versionUUID = versionUUID
	}

	func makeSUT() -> VersionsListStore {
		VersionsListStore(
			initialState:
				VersionList
				.State(),
			environment:
				VersionsListStore
				.Environment(
					project: expectedProject.id,
					usecase: usecase,
					mapper: mapper,
					debounceMilliseconds: 0,
					output: output
				)
		)
	}
}

extension Environment {
	static var happyPath: Environment {
		let expectedProject = Project(id: 1, name: "Name")
		let versionUUID = UUID()
		let expectedVersions = [Version(id: versionUUID, buildNumber: 1, associatedTicketKeys: ["Key"])]
		let expectedRows = [VersionList.RowState(id: versionUUID, title: "", subtitle: "")]
		let env = Environment(
			expectedProject: expectedProject,
			expectedVersions: expectedVersions,
			expectedRows: expectedRows,
			versionUUID: versionUUID
		)
		env.usecase.executeMock.returns((expectedProject, expectedVersions))
		env.mapper.mapMock.returns(expectedRows)
		return env
	}

	static var unhappyPath: Environment {
		let env = Environment()
		let testError = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ha-ha!"])
		env.usecase.executeMock.throws(testError)
		return env
	}
}

extension Environment {
	@TaskLocal static var current = Environment.happyPath
}

struct HappyPathEnvironment: TestTrait, SuiteTrait, TestScoping {
	func provideScope(
		for test: Test,
		testCase: Test.Case?,
		performing function: @Sendable () async throws -> Void
	) async throws {
		try await Environment.$current.withValue(Environment.happyPath) {
			try await function()
		}
	}
}

struct UnhappyPathEnvironment: TestTrait, SuiteTrait, TestScoping {
	func provideScope(
		for test: Test,
		testCase: Test.Case?,
		performing function: @Sendable () async throws -> Void
	) async throws {
		try await Environment.$current.withValue(Environment.unhappyPath) {
			try await function()
		}
	}
}

extension Trait where Self == HappyPathEnvironment {
	static var happyPathEnvironment: Self { Self() }
}

extension Trait where Self == UnhappyPathEnvironment {
	static var unhappyPathEnvironment: Self { Self() }
}
