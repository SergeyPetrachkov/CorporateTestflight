import CorporateTestflightDomain

protocol VersionsListPresenting {
    func showData(versions: [Version], project: Project)
    func showError(_ error: Error)
}

final class VersionsListPresenter: VersionsListPresenting {

    // MARK: - Injectables

    weak var controller: VersionsListViewControlling?

    // MARK: - Class interface

    func showData(versions: [Version], project: Project) {
        // show data in the controller
    }

    func showError(_ error: Error) {
        // show error
    }

    private func map(versions: [Version]) -> [VersionsListModels.VersionViewModel] {
        versions.map { version in
            let subtitle = buildSubtitle(for: version)
            return VersionsListModels.VersionViewModel(
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
