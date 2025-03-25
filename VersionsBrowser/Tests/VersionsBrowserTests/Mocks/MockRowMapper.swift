import MockFunc
import CorporateTestflightDomain
@testable import VersionsBrowser

final class MockRowMapper: VersionList.RowMapping {

	let mapMock = MockFunc<[CorporateTestflightDomain.Version], [VersionsBrowser.VersionList.RowState]>()
	func map(versions: [CorporateTestflightDomain.Version]) -> [VersionsBrowser.VersionList.RowState] {
		mapMock.callAndReturn(versions)
	}
}
