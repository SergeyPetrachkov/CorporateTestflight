import SimpleDI
import VersionsBrowserInterface
import CorporateTestflightDomain

public final class VersionsBrowserAssembly: Assembly {

	public init() {}

	public func assemble(container: SimpleDI.Container) {
		container.register((any VersionsBrowserCoordinator).self) { input, resolver in
			VersionsListCoordinator(input: input, factory: VersionsBrowserFactoryImpl(resolver: resolver))
		}
	}
}
