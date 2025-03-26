#if os(macOS)
import AppKit
extension NSImage: @retroactive @unchecked Sendable {}

extension NSImage {
	public func pngData() -> Data? {
		guard
			let tiffData = self.tiffRepresentation,
			let bitmap = NSBitmapImageRep(data: tiffData)
		else { return nil }
		return bitmap.representation(using: .png, properties: [:])
	}

	public convenience init?(systemName: String, variableValue: Double) {
		self.init(systemSymbolName: systemName, variableValue: variableValue, accessibilityDescription: nil)
	}
}

public typealias LoadableImage = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
import UIKit
public typealias LoadableImage = UIImage
#endif

import Foundation

public protocol ImageLoader: Sendable {
	func load(url: URL) async throws -> LoadableImage
}
