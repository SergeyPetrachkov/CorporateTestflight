import SimpleDI
import VersionsBrowserInterface
import CorporateTestflightDomain

// Plan 7:
// An assembly of the versions browser. MainActor, preconcurrency.

@MainActor
public final class VersionsBrowserAssembly: @preconcurrency Assembly {

	public init() {}

	public func assemble(container: SimpleDI.Container) {
		container.register((any VersionsBrowserCoordinator).self) { input, resolver in
			VersionsListCoordinator(input: input, factory: VersionsBrowserFactoryImpl(resolver: resolver))
		}
	}
}
