import Fluent

struct CreateTickets: AsyncMigration {

    private let prepopulatedData: [Ticket] = [
        .init(key: "JIRA-1", title: "Set up a welcome screen", description: "As a user\nWhen I open an app for the first time\nI want to see a welcome screen"),
        .init(
            key: "JIRA-2",
            title: "Create an onboarding flow pt I",
            description: "As a user\nWhen I open an app for the first time\nI want to be onboarded to the app's features"
        ),
        .init(
            key: "JIRA-3",
            title: "Create an onboarding flow pt II",
            description: "As a user\nWhen I open an app for the first time\nI want to be onboarded to the app's features"
        ),
        .init(key: "JIRA-4", title: "Integrate the onboarding flow into the main app", description: "No description"),
        .init(key: "JIRA-5", title: "Create a dashboard screen for the user", description: "No description"),
        .init(
            key: "JIRA-6",
            title: "Make the dashboard customizable",
            description: "As a user\nI want to be able to customize my dashboard\nSo I only see the relevant features"
        ),
        .init(key: "JIRA-7", title: "Dummy ticket", description: "Nothing to see here"),
        .init(key: "JIRA-8", title: "Integrate the dashboard into the main app", description: "Nothing to see here"),
        .init(key: "JIRA-9", title: "No title", description: "No description.")
    ]

    func prepare(on database: Database) async throws {
        try await database.schema(Ticket.schema)
            .id()
            .field("key", .string, .required)
            .field("title", .string, .required)
            .field("description", .string, .required)
            .create()
        for ticket in prepopulatedData {
            try await ticket.create(on: database)
        }
    }

    func revert(on database: Database) async throws {
        try await database.schema(Ticket.schema).delete()
    }
}
