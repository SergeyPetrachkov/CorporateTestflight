import Foundation
import CorporateTestflightDomain
import TestflightNetworking

protocol DependencyContaining {

    var api: TestflightAPIProviding { get }

}

final class AppDependencies: DependencyContaining {
    
    private(set) lazy var api: TestflightAPIProviding = TestflightAPIProvider(session: .shared, decoder: JSONDecoder())

}
