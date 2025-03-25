import MockFunc
import Testing
import CorporateTestflightDomain
import Foundation
@testable import VersionsBrowser

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
				initialState: VersionList
					.State(),
				environment: VersionsListStore
					.Environment(
						project: projectID,
						usecase: usecase,
						mapper: mapper,
						output: output
					)
			)
		}
	}

	@Test(
		"Start and Refresh Happy path",
		arguments: [
			VersionList.Action.start,
			VersionList.Action.refresh(fromScratch: true),
			VersionList.Action.refresh(fromScratch: false)
		]
	)
	func sendResultsInLoadedState(action: VersionList.Action) async {
		let env = Environment()
		let expectedProject = Project(id: 1, name: "Name")
		let expectedVersions = [Version(id: UUID(), buildNumber: 1, associatedTicketKeys: [])]
		env.usecase.executeMock.returns((expectedProject, expectedVersions))
		let expectedRows = [VersionList.RowState(id: UUID(), title: "", subtitle: "")]
		env.mapper.mapMock.returns(expectedRows)
		let sut = env.makeSUT()

		await sut.send(action)

		#expect(env.usecase.executeMock.input == env.projectID)
		#expect(env.usecase.executeMock.calledOnce)
		#expect(env.mapper.mapMock.calledOnce)
		#expect(env.mapper.mapMock.input == expectedVersions)
		#expect(sut.state.seachTerm == "")
		#expect(sut.state.contentState == .loaded(VersionList.State.Content(projectTitle: "Name", versions: expectedRows)))
	}

	@Test(
		"Start and Refresh Unhappy path",
		arguments: [
			VersionList.Action.start,
			VersionList.Action.refresh(fromScratch: true),
			VersionList.Action.refresh(fromScratch: false)
		]
	)
	func sendFailureResultsInFailedState(action: VersionList.Action) async {
		let env = Environment()
		let testError = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ha-ha!"])

		env.usecase.executeMock.throws(testError)
		let sut = env.makeSUT()

		await sut.send(.start)

		#expect(env.usecase.executeMock.input == env.projectID)
		#expect(env.usecase.executeMock.calledOnce)
		#expect(!env.mapper.mapMock.called)
		#expect(sut.state.seachTerm == "")
		#expect(sut.state.contentState == .failed(VersionList.State.ErrorState(localizedDescription: "Ha-ha!")))
	}

	@Test(
		"Search Happy Path",
		arguments: [
			VersionList.Action.search,
			VersionList.Action.debouncedSearch
		]
	)
	func searchHappyPath(action: VersionList.Action) async {
		let env = Environment()
		let expectedProject = Project(id: 1, name: "Name")
		let expectedVersions = [Version(id: UUID(), buildNumber: 1, associatedTicketKeys: ["Key"])]
		env.usecase.executeMock.returns((expectedProject, expectedVersions))
		let expectedRows = [VersionList.RowState(id: UUID(), title: "", subtitle: "")]
		env.mapper.mapMock.returns(expectedRows)
		let sut = env.makeSUT()
		sut.state.seachTerm = "Key"

		await sut.send(.start) // to load the project
		await sut.send(action)

		#expect(env.usecase.executeMock.input == env.projectID)
		#expect(env.usecase.executeMock.calledOnce)
		#expect(env.mapper.mapMock.count == 2)
		#expect(env.mapper.mapMock.input == expectedVersions)
		#expect(sut.state.seachTerm == "Key")
		#expect(sut.state.contentState == .loaded(VersionList.State.Content(projectTitle: "Name", versions: expectedRows)))
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

	@Test
	func tapVersionHappyPath() async {
		var env = Environment()
		let expectedProject = Project(id: 1, name: "Name")
		let uuid = UUID()
		let existingVersion = Version(id: uuid, buildNumber: 1, associatedTicketKeys: ["Key"])
		let expectedVersions = [existingVersion]
		env.usecase.executeMock.returns((expectedProject, expectedVersions))
		let existingRow = VersionList.RowState(id: uuid, title: "", subtitle: "")
		let expectedRows = [existingRow]
		env.mapper.mapMock.returns(expectedRows)
		var outputCalledCorrectly = false
		env.output = { argument in
			switch argument {
			case .qrRequested:
				outputCalledCorrectly = false
			case .selectedVersion(let version):
				outputCalledCorrectly = version.id == existingVersion.id
			}
		}
		let sut = env.makeSUT()

		await sut.send(.start) // to load versions
		await sut.send(.tapItem(existingRow))

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

	@Test
	func taskCancellation() async {
		let env = Environment()
		let expectedProject = Project(id: 1, name: "Name")
		let expectedVersions = [Version(id: UUID(), buildNumber: 1, associatedTicketKeys: [])]
		env.usecase.executeMock.returns((expectedProject, expectedVersions))
		let expectedRows = [VersionList.RowState(id: UUID(), title: "", subtitle: "")]
		env.mapper.mapMock.returns(expectedRows)
		let sut = env.makeSUT()

		let task = Task { await sut.send(.start) }
		task.cancel()

		#expect(sut.state.contentState == .loading)
	}
}

