import SimpleDI
import QRReaderInterface

@MainActor
public final class QRReaderAssembly: @MainActor Assembly {

	public init() {}

	public func assemble(container: Container) {
		container.register((any QRReaderFlowCoordinating).self) { inputParameters, resolver in
			QRReaderFlowCoordinator(input: inputParameters, factory: QRReaderFlowFactoryImpl(resolver: resolver))
		}
	}
}
