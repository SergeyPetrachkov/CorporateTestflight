import Foundation
import TestflightNetworking

public final class DispatchQueueImageCache: ImageLoader, @unchecked Sendable {

	public enum ImageCacheError: Error, Equatable {
		case failedDownloadingImage(URL)
	}

	// MARK: - Injectables
	private let apiService: TestflightAPIProviding
	private let queue = DispatchQueue(label: "DispatchQueueImageCache.syncQueue")

	// MARK: - State
	private let cache: NSCache<NSURL, LoadableImage> = {
		let cache = NSCache<NSURL, LoadableImage>()
		cache.countLimit = 3
		cache.evictsObjectsWithDiscardedContent = true
		cache.name = "com.corporate-testflight.ImageCache"
		return cache
	}()

	private var registeredTasks: [URL: Task<LoadableImage, any Error>] = [:]

	// MARK: - Initializer
	public init(apiService: TestflightAPIProviding) {
		self.apiService = apiService
	}

	/// Load an image by a given URL.
	public func load(url: URL) async throws -> LoadableImage {
		if let cachedImage = cache.object(forKey: url as NSURL) {
			return cachedImage
		}
		let loadingTask = getOrCreateTask(for: url)

		return try await loadingTask.value
	}

	private func getOrCreateTask(for url: URL) -> Task<LoadableImage, any Error> {
		queue.sync {
			if let currentActiveTask = registeredTasks[url] {
				return currentActiveTask
			} else {
				let newLoadingTask = fetchImageTask(for: url)
				registeredTasks[url] = newLoadingTask
				return newLoadingTask
			}
		}
	}

	/// Create a new Task that handles the fetch request and puts it into the cache.
	private func fetchImageTask(for url: URL) -> Task<LoadableImage, any Error> {
		Task {
			defer {
				queue.sync {
					registeredTasks[url] = nil
				}
			}
			let responseData = try await apiService.getResource(url: url)
			guard let image = LoadableImage(data: responseData) else {
				throw ImageCacheError.failedDownloadingImage(url)
			}

			cache.setObject(image, forKey: url as NSURL, cost: responseData.count)

			return image
		}
	}
}
