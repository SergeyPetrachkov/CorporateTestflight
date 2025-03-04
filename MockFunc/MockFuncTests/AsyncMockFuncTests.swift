import Foundation
import MockFunc
import Testing

@Suite
struct AsyncMockFuncTests {

	@Test
	func threadSafetyCheck() async throws {
		let sut = MockImageLoader()
		await sut.purgeAsyncMock.returns()

		await withTaskGroup(of: Void.self) { group in
			for _ in 0..<1000 {
				group.addTask {
					await sut.purgeAsync()
				}
			}
			for await _ in group { }
		}

		#expect(await sut.purgeAsyncMock.invocations.count == 1000)
	}

	@Test
	func threadSafetyActorCheck() async throws {
		let sut = ActorMock()
		await sut.purgeAsyncMock.returns()

		await withTaskGroup(of: Void.self) { group in
			for _ in 0..<1000 {
				group.addTask {
					await sut.purgeAsync()
				}
			}
			for await _ in group { }
		}

		#expect(await sut.purgeAsyncMock.invocations.count == 1000)
	}

	@Suite("Async Regular Mock Func")
	struct ThreadSafeRegularMockFunc {
		@Test
		func threadSafeMockFuncGetsCalled() async {
			let sut = MockImageLoader()
			let imageToReturn = Image(data: Data())

			await sut.loadAsyncUrlMock.returns(imageToReturn)

			let result = await sut.loadAsync(url: URL.sample)

			#expect(await sut.loadAsyncUrlMock.called)
			#expect(await sut.loadAsyncUrlMock.calledOnce)
			#expect(await sut.loadAsyncUrlMock.input == URL.sample)
			#expect(await sut.loadAsyncUrlMock.output == imageToReturn)
			#expect(result == imageToReturn)
		}

		@Test
		func threadSafeSucceedsMock() async throws {
			let sut = MockImageLoader()
			let imageToReturn = Image(data: Data())

			await sut.loadAsyncResultMock.succeeds(imageToReturn)

			_ = await sut.loadAsyncResult(url: URL.sample)

			#expect(await sut.loadAsyncResultMock.called)
			#expect(await sut.loadAsyncResultMock.calledOnce)
			#expect(await sut.loadAsyncResultMock.input == URL.sample)
			#expect(try await sut.loadAsyncResultMock.output.get() == imageToReturn)
		}

		@Test
		func threadSafeFailsMock() async {
			let sut = MockImageLoader()
			await sut.loadAsyncResultMock.fails(URLError(.badURL))

			_ = await sut.loadAsyncResult(url: URL.sample)

			#expect(await sut.loadAsyncResultMock.called)
			#expect(await sut.loadAsyncResultMock.calledOnce)
			#expect(await sut.loadAsyncResultMock.input == URL.sample)
			await #expect(throws: URLError(.badURL), performing: { try await sut.loadAsyncResultMock.output.get() })
		}

		@Test
		func threadSafeVoidMock() async {
			let sut = MockImageLoader()
			await sut.purgeAsyncMock.returns()

			await sut.purgeAsync()

			#expect(await sut.purgeAsyncMock.called)
			#expect(await sut.purgeAsyncMock.calledOnce)
		}

		@Test
		func threadSafeOptionalMock() async {
			let sut = MockImageLoader()
			await sut.lastLoadedAsyncMock.returnsNil()

			let result = await sut.lastLoadedAsync()

			#expect(await sut.lastLoadedAsyncMock.called)
			#expect(await sut.lastLoadedAsyncMock.calledOnce)
			#expect(result == nil)
		}

		@Test
		func threadSafeResultWithVoidSuccessMock() async {
			let sut = MockImageLoader()
			await sut.purgeWithResultAsyncMock.succeeds()

			await confirmation { confirm in
				await sut.purgeWithResultAsyncMock.whenCalled {
					confirm()
				}
				_ = await sut.purgeWithResultAsync()
			}

			#expect(await sut.purgeWithResultAsyncMock.called)
			#expect(await sut.purgeWithResultAsyncMock.calledOnce)
		}
	}

	@Suite("Async Throwing MockFunc")
	struct ThreadSafeThrowingMockFuncTests {

		@Test
		func threadSafeThrowingMockFuncHappyPath() async throws {
			let sut = MockImageLoader()
			let imageToReturn = Image(data: Data())

			await sut.loadAsyncThrowsUrlMock.returns(imageToReturn)

			let result = try await sut.loadAsyncThrows(url: URL.sample)

			#expect(await sut.loadAsyncThrowsUrlMock.called)
			#expect(await sut.loadAsyncThrowsUrlMock.calledOnce)
			#expect(await sut.loadAsyncThrowsUrlMock.input == URL.sample)
			#expect(try await sut.loadAsyncThrowsUrlMock.output == imageToReturn)
			#expect(result == imageToReturn)
		}

		@Test
		func threadSafeThrowingMockFuncUnhappyPth() async throws {
			let sut = MockImageLoader()

			await sut.loadAsyncThrowsUrlMock.throws(URLError(.badURL))

			await #expect(throws: URLError(.badURL), performing: { try await sut.loadAsyncThrows(url: URL.sample) })
			#expect(await sut.loadAsyncThrowsUrlMock.called)
			#expect(await sut.loadAsyncThrowsUrlMock.calledOnce)
			#expect(await sut.loadAsyncThrowsUrlMock.input == URL.sample)
		}

		@Test
		func throwingVoidThreadSafeMock() async throws {
			let sut = MockImageLoader()
			await sut.purgeAsyncThrowingMock.returns()

			try await sut.purgeAsyncThrows()

			#expect(await sut.purgeAsyncThrowingMock.calledOnce)
		}

		@Test
		func throwingOptionalSyncMock() async throws {
			let sut = MockImageLoader()
			await sut.lastLoadedThrowingAsyncMock.returnsNil()

			try await confirmation { confirm in
				await sut.lastLoadedThrowingAsyncMock.whenCalled { _ in
					confirm()
				}
				_ = try await sut.lastLoadedAsyncThrows()
			}

			#expect(await sut.lastLoadedThrowingAsyncMock.called)
		}
	}
}
