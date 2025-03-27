#if targetEnvironment(simulator)
	import SwiftUI
	import UIKit
	import CoreImage.CIFilterBuiltins

	func generateImage() -> UIImage {
		let context = CIContext()
		let filter = CIFilter.qrCodeGenerator()
		filter.message = "ticket:JIRA-1".data(using: .utf8)!

		if let outputImage = filter.outputImage {
			if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
				return UIImage(cgImage: cgImage)
			}
		}

		return UIImage(systemName: "xmark.circle") ?? UIImage()
	}
#endif
