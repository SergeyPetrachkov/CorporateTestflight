import Fluent

struct CreateVersions: AsyncMigration {

    private let prepopulatedData: [Version] = [
        .init(buildNumber: 1, releaseNotes: "The very first build 🥇", associatedTicketKeys: []),
        .init(buildNumber: 2, releaseNotes: "Added analytics dependencies and set up the welcome screen 🤗", associatedTicketKeys: ["JIRA-1"]),
        .init(buildNumber: 3, releaseNotes: "Created the onboarding flow ⛴️", associatedTicketKeys: ["JIRA-2", "JIRA-3", "JIRA-4"]),
        .init(buildNumber: 4, releaseNotes: "Created the dashboard for the authorized user 🎛️", associatedTicketKeys: ["JIRA-4", "JIRA-5", "JIRA-6", "JIRA-7", "JIRA-8", "JIRA-9"]),
        .init(buildNumber: 5, releaseNotes: "💰Created the in-app-purchase flow 💸", associatedTicketKeys: ["JIRA-9", "JIRA-10"]),
    ]

    func prepare(on database: Database) async throws {
        try await database.schema(Version.schema)
            .id()
            .field("buildNumber", .int32, .required)
            .field("releaseNotes", .string)
            .field("associatedTicketKeys", .array(of: .string), .required)
            .create()
        for version in prepopulatedData {
            try await version.create(on: database)
        }
    }

    func revert(on database: Database) async throws {
        try await database.schema(Version.schema).delete()
    }
}
