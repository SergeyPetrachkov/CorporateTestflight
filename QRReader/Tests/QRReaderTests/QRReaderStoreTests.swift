import AVFoundation
import Testing
import QRReaderInterface
import MockFunc
@testable import QRReader

// Plan: 14 QR Store Tests
// start coverage
// async stream (starts immediately!)
// output testing? MockFunc and @Mock to the rescue again

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

	}

	@Test("Store handles scanned QR code")
	func storeHandlesScannedCode() async {
		let env = Environment()
		let expectedCode = "expected-code"

	}

	@Test("Store stops scanning on stop action")
	func storeStopsScanning() async {
		let env = Environment()

	}

	@Test("Store handles tap on scanned content")
	func storeHandlesTapOnScannedContent() async {
		let env = Environment()
		let sut = env.makeSUT()
		let expectedCode = "test-qr-code"

		await sut.send(.tapScannedContent(expectedCode))

		#expect(env.$output.assignments == [.codeRetrieved(expectedCode)])
	}

	//	@Test("Store removes duplicate QR codes", .timeLimit(.minutes(1))) <---- Only in minutes, why apple?
	@Test("Store removes duplicate QR codes")
	func storeRemovesDuplicates() async {
		await withKnownIssue(isIntermittent: true) {
			let env = Environment()

			let expectedCode = "expected-code"

			let sut = env.makeSUT()
			let collectingTask = Task {
				var codes: [String?] = []
				for await newState in sut.$state.values {
					codes.append(newState.scannedCode)
					if codes.count >= 3 {
						break
					}
				}
				return codes
			}

			// this starts immediately, so there's a race condition between collecting task and this one
			let fakeStream = AsyncStream<String> { continuation in
				continuation.yield("somethingElse")
				continuation.yield(expectedCode)
				continuation.yield(expectedCode)
				continuation.finish()
			}

			env.qrListener.startStreamMock.returns(fakeStream)

			await sut.send(.start)

			// this makes sure that the test has a timeout and doesn't result in an infinite loop
			Task {
				try await Task.sleep(for: .seconds(1))
				collectingTask.cancel()
			}
			let codes = await collectingTask.value

			#expect(sut.state.scannedCode == expectedCode)
			#expect(codes == [nil, "somethingElse", expectedCode])
		}
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
