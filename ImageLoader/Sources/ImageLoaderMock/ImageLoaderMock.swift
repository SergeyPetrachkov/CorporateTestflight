import Foundation
import ImageLoader
import MockFunc

public final class ImageLoaderMock: ImageLoader {

	public init() {}

	public let loadMock = ThreadSafeMockThrowingFunc<URL, LoadableImage>()
	public func load(url: URL) async throws -> LoadableImage {
		try await loadMock.callAndReturn(url)
	}
}
