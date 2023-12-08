import CorporateTestflightDomain

extension VersionDetailsViewModel {

    enum State {

        // MARK: - Nested VMs

        struct VersionHeaderViewModel {
            let title: String
            let body: String?

            init(version: Version) {
                self.title = "Build: #\(version.buildNumber)"
                self.body = version.releaseNotes
            }
        }

        struct VersionPreviewViewModel {
            let headerViewModel: VersionHeaderViewModel
            let ticketPlaceholdersCount: Int

            init(version: Version) {
                self.headerViewModel = .init(version: version)
                self.ticketPlaceholdersCount = version.associatedTicketKeys.count
            }
        }

        struct LoadedVersionDetailsViewModel {

            struct TicketViewModel: Identifiable {
                let key: String
                let title: String
                let body: String

                var id: String {
                    key
                }

                init(ticket: Ticket) {
                    self.key = ticket.key
                    self.title = ticket.title
                    self.body = ticket.description
                }
            }

            let headerViewModel: VersionHeaderViewModel
            let ticketsModels: [TicketViewModel]

            init(version: Version, tickets: [Ticket]) {
                self.headerViewModel = .init(version: version)
                self.ticketsModels = tickets.map(TicketViewModel.init)
            }
        }

        // MARK: - Cases

        case loading(VersionPreviewViewModel)
        case loaded(LoadedVersionDetailsViewModel)
        case failed(Error)
    }
}
