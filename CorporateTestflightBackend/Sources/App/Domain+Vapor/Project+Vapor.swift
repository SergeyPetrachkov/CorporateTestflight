import CorporateTestflightDomain
import Vapor

extension CorporateTestflightDomain.Project: @retroactive AsyncResponseEncodable {}
extension CorporateTestflightDomain.Project: @retroactive AsyncRequestDecodable {}
extension CorporateTestflightDomain.Project: @retroactive ResponseEncodable {}
extension CorporateTestflightDomain.Project: @retroactive RequestDecodable {}
extension CorporateTestflightDomain.Project: @retroactive Content {}
