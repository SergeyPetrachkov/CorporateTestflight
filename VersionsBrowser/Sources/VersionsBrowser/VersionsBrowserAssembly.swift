import SimpleDI
import VersionsBrowserInterface

@MainActor
public final class VersionsBrowserAssembly: @preconcurrency Assembly {

	public init() {}

	public func assemble(container: SimpleDI.Container) {
		container.register((any VersionsBrowserCoordinator).self) { input, _ in
			VersionsListCoordinator(input: input)
		}
	}
}
