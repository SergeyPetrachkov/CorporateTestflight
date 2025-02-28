import AVFoundation
import SimpleDI
import QRReaderInterface

@MainActor
public final class QRReaderAssembly: @preconcurrency Assembly {

	public init() {

	}

	public func assemble(container: Container) {
		container.register((any QRReaderFlowCoordinating).self) { inputParameters, _ in
			QRReaderFlowCoordinator(input: inputParameters)
		}		
	}
}
