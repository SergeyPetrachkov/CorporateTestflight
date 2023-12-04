import CorporateTestflightDomain

protocol VersionsListPresenting {
    @MainActor
    func showData(versions: [Version], project: Project)
}

final class VersionsListPresenter: VersionsListPresenting {

    weak var controller: VersionsListViewControlling?

    @MainActor // TODO: make mapping outside of the main thread
    func showData(versions: [Version], project: Project) {
        let mappedViewModels = versions.map { version in
            let subtitle = buildSubtitle(for: version)
            return VersionsListModels.VersionViewModel(
                id: version.id,
                title: "Build: \(version.buildNumber)", 
                subtitle: subtitle
            )
        }
        controller?.showVersions(mappedViewModels)
        controller?.showProjectName(project.name)
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
