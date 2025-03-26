import Combine
import CorporateTestflightDomain
import Foundation
import TestflightFoundation
import UniFlow

// Plan:
// Simple Store
// Refreshable + Cancellation
// Interface module

final class JiraViewerStore: Store, ObservableObject {

	typealias State = JiraViewer.State
	typealias Environment = JiraViewer.Environment
	typealias Action = JiraViewer.Action

	private(set) var environment: Environment
	@Published var state: State

	init(initialState: State, environment: Environment) {
		self.environment = environment
		self.state = initialState
	}

	deinit {
		print("❌ deinit \(self)")
	}

	func send(_ action: Action) async {
		print("'action: \(action)' >> 'state: \(state)'")
		switch action {
		case .start, .refresh:
			state.footer = .loading
			do {
				if !isTicketValid(ticket: environment.ticket) {
					let fullTicket = try await environment.ticketsRepository.getTicket(key: environment.ticket.key)
					environment.ticket = fullTicket
					state.header = JiraViewer.TicketHeaderState(
						title: fullTicket.title,
						key: fullTicket.key,
						description: fullTicket.description
					)
				}
				if Task.isCancelled {
					print("Task is cancelled, no attachments will be loaded")
					return
				}
				if let attachmentsToLoad = environment.ticket.attachments {
					let attachments = try await environment.attachmentLoader.execute(attachments: attachmentsToLoad)
					if Task.isCancelled {
						print("Task is cancelled, no attachments will be displayed")
						return
					}
					state.footer = .loaded(
						JiraViewer.TicketAttachmentsState(
							images: attachments.map { JiraViewer.LoadedImage(resourceURL: $0.0, image: $0.1) }
						)
					)
				} else {
					state.footer = .loaded(
						JiraViewer.TicketAttachmentsState(
							images: []
						)
					)
				}
			}
			catch {
				if Task.isCancelled {
					print("Task is cancelled, no error will be displayed")
					return
				}
				state.footer = .failed(.init(description: error.localizedDescription))
			}
		}
		print("state >> '\(state)'")
	}

	private func isTicketValid(ticket: Ticket) -> Bool {
		ticket.id != UUID.zero
	}
}
