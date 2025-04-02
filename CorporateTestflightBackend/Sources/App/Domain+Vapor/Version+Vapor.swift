import CorporateTestflightDomain
import Vapor

extension CorporateTestflightDomain.Version: @retroactive AsyncResponseEncodable {}
extension CorporateTestflightDomain.Version: @retroactive AsyncRequestDecodable {}
extension CorporateTestflightDomain.Version: @retroactive ResponseEncodable {}
extension CorporateTestflightDomain.Version: @retroactive RequestDecodable {}
extension CorporateTestflightDomain.Version: @retroactive Content {}
