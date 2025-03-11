import AVFoundation
import Testing
import QRReaderInterface
import MockFunc
@testable import QRReader

@Suite("QR Reader Store Tests")
@MainActor
struct QRReaderStoreTests {

	@MainActor
	struct Environment {
		let session = AVCaptureSession()
		let qrListener = MockQRCodeCaptureListener()
		@Mock
		var output: QRReaderFlowResult

		func makeSUT() -> QRReaderStore {
			let environment = QRCode.Environment(
				qrListener: qrListener,
				output: { result in
					output = result
				}
			)
			let state = QRCode.State(session: session)
			return QRReaderStore(initialState: state, environment: environment)
		}
	}

	@Test("Store starts QR code scanning")
	func storeStartsScanning() async {

		let env = Environment()
		let fakeStream = AsyncStream<String> { continuation in
			continuation.finish()
		}
		env.qrListener.startStreamMock.returns(fakeStream)
		let sut = env.makeSUT()

		await sut.send(.start)

		#expect(env.qrListener.startStreamMock.calledOnce)
	}

	@Test("Store handles scanned QR code")
	func storeHandlesScannedCode() async {
		let env = Environment()
		let expectedCode = "expected-code"
		let fakeStream = AsyncStream<String> { continuation in
			continuation.yield(expectedCode)
			continuation.finish()
		}
		env.qrListener.startStreamMock.returns(fakeStream)
		let sut = env.makeSUT()

		await sut.send(.start)

		#expect(env.qrListener.startStreamMock.calledOnce)
		#expect(sut.state.scannedCode == expectedCode)
	}

	@Test("Store stops scanning on stop action")
	func storeStopsScanning() async {
		let env = Environment()
		env.qrListener.stopMock.returns()
		let sut = env.makeSUT()

		await sut.send(.stop)

		#expect(env.qrListener.stopMock.calledOnce)
	}

	@Test("Store handles tap on scanned content")
	func storeHandlesTapOnScannedContent() async {
		let env = Environment()
		let sut = env.makeSUT()
		let expectedCode = "test-qr-code"

		await sut.send(.tapScannedContent(expectedCode))

		#expect(env.$output.assignments == [.codeRetrieved(expectedCode)])
	}

	@Test("Store removes duplicate QR codes")
	func storeRemovesDuplicates() async {
		let env = Environment()

		let expectedCode = "expected-code"
		let fakeStream = AsyncStream<String> { continuation in
			continuation.yield("somethingElse")
			continuation.yield(expectedCode)
			continuation.yield(expectedCode)
			continuation.finish()
		}
		env.qrListener.startStreamMock.returns(fakeStream)
		let sut = env.makeSUT()

		let collectingTask = Task {
			var codes: [String?] = []

			for await newState in sut.$state.values {
				codes.append(newState.scannedCode)
				if codes.count == 3 {
					break
				}
			}
			return codes
		}


		await sut.send(.start)
		let codes = await collectingTask.value

		#expect(sut.state.scannedCode == expectedCode)
		#expect(codes == [nil, "somethingElse", expectedCode])
	}
}

final class MockQRCodeCaptureListener: QRCodeCaptureListening {

	let startMock = MockFunc<Void, Void>()
	func start() {
		startMock.callAndReturn()
	}

	let stopMock = MockFunc<Void, Void>()
	func stop() {
		stopMock.callAndReturn()
	}

	let startStreamMock = MockFunc<Void, AsyncStream<String>>()
	func startStream() -> AsyncStream<String> {
		startStreamMock.callAndReturn()
	}
}
