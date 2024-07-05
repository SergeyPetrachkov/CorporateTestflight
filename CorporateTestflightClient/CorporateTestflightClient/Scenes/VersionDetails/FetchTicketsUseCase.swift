import CorporateTestflightDomain
import Foundation

protocol FetchTicketsUseCaseProtocol: Sendable {
    func execute(for version: Version) async throws -> [Ticket]
}

struct FetchTicketsUseCase: FetchTicketsUseCaseProtocol {

    private let ticketsRepository: TicketsRepository

    init(ticketsRepository: TicketsRepository) {
        self.ticketsRepository = ticketsRepository
    }

    func execute(for version: Version) async throws -> [Ticket] {
        try await withThrowingTaskGroup(of: Ticket?.self) { group in
            version.associatedTicketKeys.forEach { ticketKey in
                group.addTask {
                    do {
                        return try await ticketsRepository.getTicket(key: ticketKey)
                    }
                    catch let urlError as URLError {
                        throw CancellationError()
                    }
                    catch {
                        print(error)
                        return nil
                    }
                }
            }
            var tickets: [Ticket] = []
            for try await ticket in group {
                if let ticket {
                    tickets.append(ticket)
                }
            }
            return tickets
        }
    }
}
