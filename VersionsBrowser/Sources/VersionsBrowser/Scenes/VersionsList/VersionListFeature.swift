import CorporateTestflightDomain
import Foundation

enum VersionList {

	struct State: CustomDebugStringConvertible, Equatable {

		struct Content: Equatable {
			let projectTitle: String
			let versions: [RowState]
		}

		struct ErrorState: Equatable {
			let localizedDescription: String
		}

		enum ContentState: Equatable {
			case loading
			case loaded(Content)
			case failed(ErrorState)
		}

		var seachTerm: String = ""
		var contentState: ContentState

		var debugDescription: String {
			switch self.contentState {
			case .loaded(let content):
				"loaded: builds_count=\(content.versions.count); search_term='\(seachTerm)'"
			case .failed(let error):
				"failed: \(error.localizedDescription); search_term='\(seachTerm)'"
			case .loading:
				"loading; search_term='\(seachTerm)'"
			}
		}

		init(seachTerm: String, contentState: ContentState) {
			self.seachTerm = seachTerm
			self.contentState = contentState
		}

		init() {
			self.init(seachTerm: "", contentState: .loading)
		}
	}

	enum Action: Sendable, CustomDebugStringConvertible {
		case start
		case refresh(fromScratch: Bool)
		case tapItem(RowState)
		case tapQR
		case search
		case debouncedSearch

		var debugDescription: String {
			switch self {
			case .start:
				"start"
			case .refresh(let fromScratch):
				"refresh: from_scratch=\(fromScratch)"
			case .tapItem(let rowState):
				"tap: row_id=\(rowState.id)"
			case .tapQR:
				"tap: qr_code"
			case .search:
				"search"
			case .debouncedSearch:
				"debounced_search"
			}
		}
	}

	struct RowState: Equatable, Hashable, Identifiable {
		let id: UUID
		let title: String
		let subtitle: String
	}

	struct Environment {
		enum Output: Sendable {
			case selectedVersion(Version)
			case qrRequested
		}

		let project: Project.ID
		let usecase: FetchProjectAndVersionsUsecase
		let mapper: RowMapping
		let debounceMilliseconds: Int

		let output: @MainActor (Output) -> Void

		init(
			project: Project.ID,
			usecase: FetchProjectAndVersionsUsecase,
			mapper: RowMapping,
			debounceMilliseconds: Int = 300,
			output: @escaping @MainActor (Output) -> Void
		) {
			self.project = project
			self.usecase = usecase
			self.mapper = mapper
			self.debounceMilliseconds = debounceMilliseconds
			self.output = output
		}
	}

	protocol RowMapping: Sendable {
		func map(versions: [Version]) -> [RowState]
	}

	struct RowMapper: RowMapping {
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
