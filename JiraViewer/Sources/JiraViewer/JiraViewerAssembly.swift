import JiraViewerInterface
import SimpleDI

@MainActor
public final class JiraViewerAssembly: @preconcurrency Assembly {

	public init() {}

	public func assemble(container: Container) {
		container.register((any JiraViewerFlowCoordinating).self) { inputParameters, _ in
			JiraViewerFlowCoordinator(
				input: inputParameters
			)
		}
	}
}
