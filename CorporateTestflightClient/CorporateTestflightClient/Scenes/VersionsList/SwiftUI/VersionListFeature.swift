import CorporateTestflightDomain
import Foundation

enum VersionList {

	indirect enum State {
		struct Content {
			let projectTitle: String
			let versions: [RowState]
		}

		case initial
		case loaded(Content)
		case failed(Error)
		case loading
	}

	enum Action {
		case start
		case refresh(fromScratch: Bool)
		case tapItem(RowState)
	}

	struct RowState: Equatable, Hashable, Identifiable {
		let id: UUID
		let title: String
		let subtitle: String
	}

	struct Environment {
		let project: Project.ID
		let usecase: FetchProjectAndVersionsUsecase
		let mapper: RowMapper
		let output: @MainActor (_ version: Version) -> Void

		var versions: [Version] = []
	}

	struct RowMapper {
		func map(versions: [Version]) -> [RowState] {
			versions.map { version in
				let subtitle = buildSubtitle(for: version)
				return RowState(
					id: version.id,
					title: "Build: \(version.buildNumber)",
					subtitle: subtitle
				)
			}
		}

		private func buildSubtitle(for version: Version) -> String {
			guard !version.associatedTicketKeys.isEmpty else {
				return "No associated tickets"
			}
			let prefix = "Associated tickets:"
			guard version.associatedTicketKeys.count > 1, let firstTicket = version.associatedTicketKeys.first else {
				return "\(prefix) \(version.associatedTicketKeys.joined(separator: ", "))"
			}
			return "\(prefix) \(firstTicket) and \(version.associatedTicketKeys.count - 1) more"
		}
	}
}

//enum Reduced<State: Sendable> {
//	case newState(State)
//	case effect(Effect)
//}
//
//enum Effect {
//	case run(@Sendable () async -> Void)
//	case none
//}

//	struct Reducer {
//
//		let env: Environment
//
//		func reduce(state: inout VersionList.State, action: VersionList.Action) async -> Effect {
//			switch action {
//			case .start:
//				guard case let .initial(projectId) = state else {
//					return .none // start can only be triggered once, huh?
//				}
//
//				do {
//					let (project, builds) = try await env.usecase.execute(projectId: projectId)
//					state = .loaded(.init(project: project, versions: builds))
//				} catch {
//					state = .failed(error)
//				}
//
//				return .none
//			case .tapItem:
//				return .none
//			}
//		}
//	}

//struct Reducer {
//
//	let env: Environment
//
//	func reduce(state: VersionList.State, action: VersionList.Action) async -> Reduced<VersionList.State> {
//		switch action {
//		case .start:
//			guard case let .initial(projectId) = state else {
//				return .effect(.none) // start can only be triggered once, huh?
//			}
//
//			do {
//				let (project, builds) = try await env.usecase.execute(projectId: projectId)
//				return .newState(.loaded(.init(project: project, versions: builds)))
//			} catch {
//				return .newState(.failed(error))
//			}
//		case .tapItem:
//			return .effect(.none)
//		}
//	}
//}
