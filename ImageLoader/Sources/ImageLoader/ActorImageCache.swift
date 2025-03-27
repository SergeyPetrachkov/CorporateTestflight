import Foundation
import TestflightNetworking

public actor ImageCache: ImageLoader {

	public enum ImageCacheError: Error, Equatable {
		case failedDownloadingImage(URL)
	}

	// MARK: - Injectables
	let apiService: TestflightAPIProviding

	// MARK: - Initializers
	public init(apiService: TestflightAPIProviding) {
		self.apiService = apiService
	}

	// MARK: - State
	private let cache: NSCache<NSURL, LoadableImage> = {
		let cache = NSCache<NSURL, LoadableImage>()
		cache.countLimit = 3  // we set it up to play around with loading images
		cache.evictsObjectsWithDiscardedContent = true
		cache.name = "com.corporate-testflight.ImageCache"
		return cache
	}()

	private var registeredTasks: [URL: Task<LoadableImage, any Error>] = [:]

	/// Load an image by a given URL.
	///
	/// This function reaches out to cache and returns a cached image for the given URL if any.
	/// Otherwise, it checks if there’s an ongoing task for the same URL to avoid double computation and await that task.
	/// Finally, if there’s not task registered or the previous task for this URL failed, it starts a new task.
	public func load(url: URL) async throws -> LoadableImage {

		// if we have an object in the cache, we use it
		if let cachedImage = cache.object(forKey: url as NSURL) {
			return cachedImage
		}
		// if we’ve already registered a task for the url, we just await it, not start another one
		if let currentActiveTask = registeredTasks[url] {
			do {
				let cachedImage = try await currentActiveTask.value
				return cachedImage
			} catch {
				print("Previously cached task for the image \(url) returned error \(error)")
			}
		}

		let newLoadingTask = fetchImageTask(for: url)
		registeredTasks[url] = newLoadingTask
		return try await newLoadingTask.value
	}

	/// Create a new Task that handles the fetch request and puts it into the cache.
	private func fetchImageTask(for url: URL) -> Task<LoadableImage, any Error> {
		Task {
			defer {
				// remove the registered task from the local dictionary no matter what
				registeredTasks[url] = nil
			}
			let responseData = try await apiService.getResource(url: url)
			guard let image = LoadableImage(data: responseData) else {
				throw ImageCacheError.failedDownloadingImage(url)
			}
			// put data to the cache
			cache.setObject(image, forKey: url as NSURL, cost: responseData.count)
			return image
		}
	}
}
