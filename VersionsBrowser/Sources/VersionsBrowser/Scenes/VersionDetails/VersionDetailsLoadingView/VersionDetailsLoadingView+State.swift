import CorporateTestflightDomain

extension VersionDetailsLoadingView {
    struct State: Equatable {
        let headerState: VersionDetailsHeaderView.State
        let ticketPlaceholdersCount: Int

        init(version: Version) {
            self.headerState = .init(version: version)
            self.ticketPlaceholdersCount = version.associatedTicketKeys.count
        }
    }
}
