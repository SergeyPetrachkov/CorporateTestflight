import Foundation

enum VersionsListModels {

    struct VersionViewModel: Equatable, Hashable {
        let id: UUID
        let title: String
        let subtitle: String
    }
}
