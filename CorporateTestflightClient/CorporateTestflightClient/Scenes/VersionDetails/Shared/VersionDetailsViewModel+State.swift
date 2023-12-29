import CorporateTestflightDomain

extension VersionDetailsViewModel {

    enum State: Equatable {

        // MARK: - Nested VMs

        struct VersionHeaderViewModel: Equatable {
            let title: String
            let body: String?

            init(version: Version) {
                self.title = "Build: #\(version.buildNumber)"
                self.body = version.releaseNotes
            }
        }

        struct VersionPreviewViewModel: Equatable {
            let headerViewModel: VersionHeaderViewModel
            let ticketPlaceholdersCount: Int

            init(version: Version) {
                self.headerViewModel = .init(version: version)
                self.ticketPlaceholdersCount = version.associatedTicketKeys.count
            }
        }

        struct LoadedVersionDetailsViewModel: Equatable {

            struct TicketViewModel: Equatable, Identifiable {
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

        struct ErrorViewModel: Equatable {
            let message: String
        }

        // MARK: - Cases

        case loading(VersionPreviewViewModel)
        case loaded(LoadedVersionDetailsViewModel)
        case failed(ErrorViewModel)
    }
}
