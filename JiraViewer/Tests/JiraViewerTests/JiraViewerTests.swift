import Testing
import CorporateTestflightDomain
import ImageLoader
import ImageLoaderMock
import Foundation
import TestflightFoundation

@testable import JiraViewer

// Plan:
// Parametric tests

@Suite("Jira Viewer Store Tests")
@MainActor
struct JiraViewerStoreTests {

	@MainActor
	struct Environment {

		let imageLoaderMock = ImageLoaderMock()
		let ticketsRepositoryMock = MockTicketsRepository()

		func makeSUT(ticket: Ticket) -> JiraViewerStore {
			let sceneEnvironment = JiraViewer.Environment(
				attachmentLoader: LoadAttachmentsUsecaseImpl(
					imageLoader: imageLoaderMock
				),
				ticketsRepository: ticketsRepositoryMock,
				ticket: ticket
			)
			return JiraViewerStore(initialState: JiraViewerStore.State(ticket: ticket), environment: sceneEnvironment)
		}
	}

	// An example of a parametric test when it's simple and nice
	@Test(
		arguments: [
			Ticket(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, key: "", title: "", description: ""),
			Ticket(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, key: "Jira-1", title: "Title1", description: "Description1"),
			Ticket(
				id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
				key: "Jira-1",
				title: "Title1",
				description: "Description1",
				attachments: []
			)
		]
	)
	func validTicketWithNoImagesShouldResultInLoadedState(ticket: Ticket) async {
		let env = Environment()

		let sut = env.makeSUT(ticket: ticket)

		await sut.send(.start)
		let resultedState = sut.state

		#expect(
			resultedState
				== JiraViewer.State(
					header: JiraViewer.TicketHeaderState(
						title: ticket.title,
						key: ticket.key,
						description: ticket.description
					),
					footer: JiraViewer.State.LoadableFooterState.loaded(
						JiraViewer.TicketAttachmentsState(
							images: []
						)
					)
				)
		)
		#expect(env.ticketsRepositoryMock.getTicketMock.count == 0)
		await #expect(env.imageLoaderMock.loadMock.count == 0)
	}

	// An example of a parametric test when it becomes complicated and triggers a question: who's gonna test the tests?
	@Test(
		arguments: [
			Ticket(
				id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
				key: "Jira-1",
				title: "Title1",
				description: "Description1",
				attachments: ["meme.jpg"]
			),
			Ticket(
				id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
				key: "Jira-1",
				title: "Title1",
				description: "Description1",
				attachments: ["meme.jpg", "meme1.jpg"]
			)
		]
	)
	func validTicketWithAttachmentsShouldLoadDataAndResultInLoadedState(ticket: Ticket) async {
		let env = Environment()
		let expectedImage = LoadableImage()
		let expectedLoadedImages =
			ticket
			.attachments?
			.compactMap {
				JiraViewer.LoadedImage(
					resourceURL: URL(string: "http://localhost:8080/images/\($0)")!,
					image: expectedImage
				)
			} ?? []
		await env.imageLoaderMock.loadMock.returns(expectedImage)

		let sut = env.makeSUT(ticket: ticket)

		await sut.send(.start)
		let resultedState = sut.state

		#expect(
			resultedState
				== JiraViewer.State(
					header: JiraViewer.TicketHeaderState(
						title: ticket.title,
						key: ticket.key,
						description: ticket.description
					),
					footer: JiraViewer.State.LoadableFooterState.loaded(
						JiraViewer.TicketAttachmentsState(
							images: expectedLoadedImages
						)
					)
				)
		)
		#expect(env.ticketsRepositoryMock.getTicketMock.count == 0)
		await #expect(env.imageLoaderMock.loadMock.count == (ticket.attachments?.count ?? 0))
	}

	@Test(
		arguments: [JiraViewer.Action.start, JiraViewer.Action.refresh]
	)
	func invalidTicketShouldLoadTicketDetailsAndResultInLoadedState(action: JiraViewer.Action) async {
		let env = Environment()
		let initialTicket = Ticket(
			id: UUID.zero,
			key: "",
			title: "",
			description: "Descr"
		)
		let expectedTicket = Ticket(
			id: UUID(
				uuidString: "00000000-0000-0000-0000-000000000001"
			)!,
			key: "Jira-1",
			title: "Title1",
			description: "Description1",
			attachments: ["meme.jpg"]
		)
		let expectedImage = LoadableImage()
		await env.imageLoaderMock.loadMock.returns(expectedImage)
		env.ticketsRepositoryMock.getTicketMock.returns(expectedTicket)
		let sut = env.makeSUT(ticket: initialTicket)

		await sut.send(action)
		let resultedState = sut.state

		#expect(
			resultedState
				== JiraViewer.State(
					header: JiraViewer.TicketHeaderState(
						title: expectedTicket.title,
						key: expectedTicket.key,
						description: expectedTicket.description
					),
					footer: JiraViewer.State.LoadableFooterState.loaded(
						JiraViewer.TicketAttachmentsState(
							images: [
								.init(resourceURL: URL(string: "http://localhost:8080/images/meme.jpg")!, image: expectedImage)
							]
						)
					)
				)
		)
		#expect(env.ticketsRepositoryMock.getTicketMock.calledOnce)
		#expect(await env.imageLoaderMock.loadMock.calledOnce)
	}

	@Test
	func failedLoadingShouldResultInFailedFooter() async {
		let env = Environment()
		let expectedTicket = Ticket(
			id: UUID(
				uuidString: "00000000-0000-0000-0000-000000000001"
			)!,
			key: "Jira-1",
			title: "Title1",
			description: "Description1",
			attachments: ["meme.jpg"]
		)
		let expectedError = NSError(
			domain: "image-loader-error-domain",
			code: -1,
			userInfo: [NSLocalizedDescriptionKey: "Fake error"]
		)
		await env.imageLoaderMock.loadMock.throws(expectedError)
		let sut = env.makeSUT(ticket: expectedTicket)

		await sut.send(.start)
		let resultedState = sut.state

		#expect(
			resultedState
				== JiraViewer.State(
					header: JiraViewer.TicketHeaderState(
						title: expectedTicket.title,
						key: expectedTicket.key,
						description: expectedTicket.description
					),
					footer: JiraViewer.State.LoadableFooterState.failed(
						.init(description: "Fake error")
					)
				)
		)
		#expect(env.ticketsRepositoryMock.getTicketMock.count == 0)
		#expect(await env.imageLoaderMock.loadMock.calledOnce)
	}
}
