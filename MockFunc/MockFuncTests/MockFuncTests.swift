import Foundation
import MockFunc
import Testing

@Suite
struct SyncMockFuncTests {

	@Suite("Sync Regular MockFunc")
	struct RegularMockFuncTests {

		@Test
		@MainActor
		func regularMockFuncWithCompletionGetsCalled() {
			let sut = MockImageLoader()
			let imageToReturn = Image(data: Data())
			let cachedImageToReturn = ImageCacheItem(imageData: imageToReturn)

			sut.loadUrlWithCompletionMock.returns((cachedImageToReturn, imageToReturn))

			sut.load(url: URL.sample, item: cachedImageToReturn) { _,_ in }

			#expect(sut.loadUrlWithCompletionMock.called)
			#expect(sut.loadUrlWithCompletionMock.calledOnce)
			#expect(sut.loadUrlWithCompletionMock.input == (url: URL.sample, item: cachedImageToReturn))
			#expect(sut.loadUrlWithCompletionMock.output == (cachedImageToReturn, imageToReturn))
			#expect(sut.loadUrlWithCompletionMock.completions.count == 1)
		}

		@Test
		func regularMockFuncWithNonIsolatedCompletionGetsCalled() async {
			let sut = MockImageLoader()
			let imageToReturn = Image(data: Data())
			let cachedImageToReturn = ImageCacheItem(imageData: imageToReturn)

			sut.loadUrlWithNonIsolatedCompletionMock.returns((cachedImageToReturn, imageToReturn))

			nonisolated(unsafe) var completionCallsCount = 0
			// we actually prove that MockFunc flattens async completions to sync code,
			// as the checks within this closure will be done synchronously before the test finishes
			let completion: @Sendable (ImageCacheItem, Image?) -> Void = { cacheItem, image in
				unsafe completionCallsCount += 1
				#expect(cacheItem == cachedImageToReturn)
				#expect(image == imageToReturn)
			}
			sut.loadNonIsolated(url: URL.sample, item: cachedImageToReturn, nonIsolatedCompletion: completion)

			#expect(sut.loadUrlWithNonIsolatedCompletionMock.called)
			#expect(sut.loadUrlWithNonIsolatedCompletionMock.calledOnce)
			#expect(sut.loadUrlWithNonIsolatedCompletionMock.input == (url: URL.sample, item: cachedImageToReturn))
			#expect(sut.loadUrlWithNonIsolatedCompletionMock.output == (cachedImageToReturn, imageToReturn))
			#expect(sut.loadUrlWithNonIsolatedCompletionMock.completions.count == 1)
			unsafe #expect(completionCallsCount == 1)
			// we call it explicitly to please sonnar qube
			sut.loadUrlWithNonIsolatedCompletionMock.completion.callAsFunction((cachedImageToReturn, imageToReturn))
			unsafe #expect(completionCallsCount == 2)
			// we call it the swift way
			sut.loadUrlWithNonIsolatedCompletionMock.completion((cachedImageToReturn, imageToReturn))
			unsafe #expect(completionCallsCount == 3)
		}

		@Test
		func regularSyncMock() {
			let sut = MockImageLoader()
			let imageToReturn = Image(data: Data())

			sut.loadUrlMock.returns(imageToReturn)

			_ = sut.load(url: URL.sample)

			#expect(sut.loadUrlMock.called)
			#expect(sut.loadUrlMock.calledOnce)
			#expect(sut.loadUrlMock.input == URL.sample)
			#expect(sut.loadUrlMock.output == imageToReturn)
			#expect(sut.loadUrlMock.completions.isEmpty)
		}

		@Test
		func regularSucceedsSyncMock() throws {
			let sut = MockImageLoader()
			let imageToReturn = Image(data: Data())

			sut.loadResultMock.succeeds(imageToReturn)

			_ = sut.loadResult(url: URL.sample)

			#expect(sut.loadResultMock.called)
			#expect(sut.loadResultMock.calledOnce)
			#expect(sut.loadResultMock.input == URL.sample)
			try #expect(sut.loadResultMock.output.get() == imageToReturn)
			#expect(sut.loadResultMock.completions.isEmpty)
		}

		@Test
		func regularFailsSyncMock() {
			let sut = MockImageLoader()
			sut.loadResultMock.fails(URLError(.badURL))

			_ = sut.loadResult(url: URL.sample)

			#expect(sut.loadResultMock.called)
			#expect(sut.loadResultMock.calledOnce)
			#expect(sut.loadResultMock.input == URL.sample)
			#expect(throws: URLError(.badURL), performing: { try sut.loadResultMock.output.get() })
			#expect(sut.loadResultMock.completions.isEmpty)
		}

		@Test
		func regularVoidSyncMock() {
			let sut = MockImageLoader()
			sut.purgeMock.returns()

			sut.purge()

			#expect(sut.purgeMock.called)
			#expect(sut.purgeMock.calledOnce)
		}

		@Test
		func regularOptionalSyncMock() {
			let sut = MockImageLoader()
			sut.lastLoadedMock.returnsNil()

			let result = sut.lastLoaded()

			#expect(sut.lastLoadedMock.called)
			#expect(sut.lastLoadedMock.calledOnce)
			#expect(result == nil)
		}

		@Test
		func regularResultWithVoidSuccessSyncMock() async {
			let sut = MockImageLoader()
			sut.purgeWithResultMock.succeeds()

			let stream = AsyncStream { continuation in
				sut.purgeWithResultMock.whenCalled { _ in
					continuation.yield()
				}
				_ = sut.purgeWithResult()
			}

			var iterator = stream.makeAsyncIterator()
			await iterator.next()

			#expect(sut.purgeWithResultMock.called)
			#expect(sut.purgeWithResultMock.calledOnce)
		}
	}

	@Suite("Sync Throwing MockFunc")
	struct ThrowingMockFuncTests {

		@Test
		func syncThrowingMockFuncHappyPath() throws {
			let sut = MockImageLoader()
			let imageToReturn = Image(data: Data())

			sut.loadUrlThrowingMock.returns(imageToReturn)

			let result = try sut.loadThrowing(url: URL.sample)

			#expect(sut.loadUrlThrowingMock.called)
			#expect(sut.loadUrlThrowingMock.calledOnce)
			#expect(sut.loadUrlThrowingMock.input == URL.sample)
			try #expect(sut.loadUrlThrowingMock.output == imageToReturn)
			#expect(result == imageToReturn)
		}

		@Test
		func syncThrowingTypedErrorMockFuncHappyPath() throws {
			let sut = MockImageLoader()
			let imageToReturn = Image(data: Data())

			sut.loadTypedThrowsMock.returns(imageToReturn)

			let result = try sut.loadTypedThrowing(url: URL.sample)

			#expect(sut.loadTypedThrowsMock.called)
			#expect(sut.loadTypedThrowsMock.calledOnce)
			#expect(sut.loadTypedThrowsMock.input == URL.sample)
			try #expect(sut.loadTypedThrowsMock.output == imageToReturn)
			#expect(result == imageToReturn)
		}

		@Test
		func syncThrowingMockFuncUnhappyPth() throws {
			let sut = MockImageLoader()

			sut.loadUrlThrowingMock.throws(URLError(.badURL))

			#expect(throws: URLError(.badURL), performing: { try sut.loadThrowing(url: URL.sample) })
			#expect(sut.loadUrlThrowingMock.called)
			#expect(sut.loadUrlThrowingMock.calledOnce)
			#expect(sut.loadUrlThrowingMock.input == URL.sample)
		}

		@Test
		func syncThrowingTypedErrorMockFuncUnhappyPth() throws {
			let sut = MockImageLoader()

			sut.loadTypedThrowsMock.throws(ImageLoadingError.test)

			#expect(throws: ImageLoadingError.test, performing: { try sut.loadTypedThrowing(url: URL.sample) })
			#expect(sut.loadTypedThrowsMock.called)
			#expect(sut.loadTypedThrowsMock.calledOnce)
			#expect(sut.loadTypedThrowsMock.input == URL.sample)
		}

		@Test
		func throwingVoidSyncMock() throws {
			let sut = MockImageLoader()
			sut.purgeThrowingMock.returns()

			try sut.purgeThrows()

			#expect(sut.purgeThrowingMock.calledOnce)
		}

		@Test
		func throwingOptionalSyncMock() async throws {
			let sut = MockImageLoader()
			sut.lastLoadedThrowingMock.returnsNil()

			let stream = AsyncThrowingStream { continuation in
				sut.lastLoadedThrowingMock.whenCalled { _ in
					continuation.yield()
				}
				do {
					_ = try sut.lastLoadedThrows()
					continuation.finish()
				} catch {
					continuation.finish(throwing: error)
				}
			}

			var iterator = stream.makeAsyncIterator()
			try await iterator.next()

			#expect(sut.lastLoadedThrowingMock.calledOnce)
		}

		@Test
		func throwingVoidWithCompletionSyncMock() throws {
			let sut = MockImageLoader()
			sut.purgeWithCompletionThrowingMock.returns()

			try sut.purgeThrows { }

			#expect(sut.purgeWithCompletionThrowingMock.calledOnce)
		}
	}
}
