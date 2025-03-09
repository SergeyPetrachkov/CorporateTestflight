import SwiftUI

struct ScannerOverlayView: View {
	let frameColor: Color
	let frameSize: CGSize

	init(
		frameColor: Color = .white,
		frameSize: CGSize = CGSize(width: 250, height: 250)
	) {
		self.frameColor = frameColor
		self.frameSize = frameSize
	}

	var body: some View {
		GeometryReader { geometry in
			ZStack {
				// Semi-transparent background
				Color.black.opacity(0.5)
					.mask(
						Rectangle()
							.overlay(
								RoundedRectangle(cornerRadius: 16)
									.frame(width: frameSize.width, height: frameSize.height)
									.blendMode(.destinationOut)
							)
					)

				// Scanner frame
				RoundedRectangle(cornerRadius: 16)
					.stroke(frameColor, lineWidth: 4)
					.frame(width: frameSize.width, height: frameSize.height)

				// Corner indicators
				CornerIndicators(color: frameColor)
					.frame(width: frameSize.width, height: frameSize.height)
			}
		}
		.ignoresSafeArea(edges: [.horizontal, .bottom])
	}
}

private struct CornerIndicators: View {
	let color: Color
	private let lineWidth: CGFloat = 4
	private let lineLength: CGFloat = 30

	var body: some View {
		GeometryReader { geometry in
			ZStack {
				// Top Left
				CornerShape()
					.stroke(color, lineWidth: lineWidth)
					.frame(width: lineLength, height: lineLength)
					.position(x: 0, y: 0)

				// Top Right
				CornerShape()
					.stroke(color, lineWidth: lineWidth)
					.rotationEffect(.degrees(90))
					.frame(width: lineLength, height: lineLength)
					.position(x: geometry.size.width, y: 0)

				// Bottom Left
				CornerShape()
					.stroke(color, lineWidth: lineWidth)
					.rotationEffect(.degrees(270))
					.frame(width: lineLength, height: lineLength)
					.position(x: 0, y: geometry.size.height)

				// Bottom Right
				CornerShape()
					.stroke(color, lineWidth: lineWidth)
					.rotationEffect(.degrees(180))
					.frame(width: lineLength, height: lineLength)
					.position(x: geometry.size.width, y: geometry.size.height)
			}
		}
	}
}

private struct CornerShape: Shape {
	func path(in rect: CGRect) -> Path {
		var path = Path()
		path.move(to: CGPoint(x: 0, y: rect.midY))
		path.addLine(to: CGPoint(x: 0, y: 0))
		path.addLine(to: CGPoint(x: rect.midX, y: 0))
		return path
	}
}

#Preview {
	ScannerOverlayView()
}
