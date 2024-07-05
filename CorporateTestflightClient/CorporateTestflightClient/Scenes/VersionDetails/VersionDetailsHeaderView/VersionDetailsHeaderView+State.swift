import CorporateTestflightDomain

extension VersionDetailsHeaderView {
    struct State: Equatable {
        let title: String
        let body: String?

        init(version: Version) {
            self.title = "Build: #\(version.buildNumber)"
            self.body = version.releaseNotes
        }
    }
}
