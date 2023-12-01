import Foundation
import CorporateTestflightDomain
import TestflightNetworking

protocol DependencyContaining {

    var api: TestflightAPIProviding { get }

    var versionsRepository: VersionsRepository { get }

}

final class AppDependencies: DependencyContaining {
    
    private(set) lazy var api: TestflightAPIProviding = TestflightAPIProvider(session: .shared, decoder: JSONDecoder())

    var versionsRepository: VersionsRepository {
        VersionsRepositoryImpl(api: api)
    }
}
