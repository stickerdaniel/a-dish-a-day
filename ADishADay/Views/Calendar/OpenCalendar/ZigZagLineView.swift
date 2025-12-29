//
//  ZigZagLineView.swift
//  calendar
//
//  Created by Daniel Sticker on 18.01.25.
//  Wow, another awesome component that creates a dynamic zigzag line using a bezier path.

import SwiftUI

struct ZigZagLineView<Content: View>: View {
  let offsetYValues: [CGFloat]
  let views: [Content]
  let lineHeight: CGFloat
  let maxWidth: CGFloat

  let variationIndex: Int = 3
  let variationFactor: CGFloat = 0.6

  init(
    offsetYValues: [CGFloat], views: [Content], lineHeight: CGFloat = 200, maxWidth: CGFloat = 900
  ) {
    self.offsetYValues = offsetYValues
    self.views = views
    self.lineHeight = lineHeight
    self.maxWidth = maxWidth
  }

  var body: some View {
    GeometryReader { geometry in
      let availableWidth = min(geometry.size.width, maxWidth)  // Constrain to max width
      let spacing = availableWidth / 5  // Dynamically calculate spacing
      let centerX = availableWidth / 2  // Center of the screen
      let lineWidth: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 16 : 20

      ZStack {
        // Draw the bezier path as a dashed line
        Path { path in
          let startX = centerX  // Start from the middle
          let startY: CGFloat = 44  // Start with some padding

          path.move(to: CGPoint(x: startX, y: startY))

          for index in 0..<views.count {
            // Dynamically calculate horizontal offset
            let offsetX = spacing * (index % 2 == 0 ? 1 : -1)
            let offsetY = offsetYValues[index]  // pre-calculated offsetY value

            // let nextIndex = min(index + 1, views.count - 1)
            // let nextOffsetY = offsetYValues[nextIndex] // next value or fallback to current
            // let nextOffsetX = spacing * (nextIndex % 2 == 0 ? 1 : -1)

            let previousIndex = index - 1
            let previousOffsetY =
              previousIndex >= 0
              ? offsetYValues[previousIndex]
              : 0
            let previousOffsetX =
              previousIndex >= 0
              ? spacing * (previousIndex % 2 == 0 ? 1 : -1)
              : 0

            // Introduce variation based on index (every other point or pattern-based)
            let inwardOffsetFactor: CGFloat =
              (index % variationIndex == variationIndex - 1)
              ? variationFactor
              : 1.0

            let previousInwardOffsetFactor: CGFloat =
              (previousIndex % variationIndex == variationIndex - 1)
              ? variationFactor
              : 1.0

            // Adjust control points dynamically based on available width
            let previousPoint = CGPoint(
              x: startX + previousOffsetX * previousInwardOffsetFactor,
              y: previousOffsetY
            )
            let currentPoint = CGPoint(
              x: startX + offsetX * inwardOffsetFactor,
              y: offsetY
            )
            //                        let nextPoint = CGPoint(
            //                            x: startX + nextOffsetX * inwardOffsetFactor,
            //                            y: nextOffsetY
            //                        )

            // Dynamic control points based on available width
            let controlFactor: CGFloat = availableWidth / 450  // Factor increases as width increases
            let control1 = CGPoint(
              x: previousPoint.x,
              y: previousPoint.y + (lineHeight / 2 * controlFactor)
            )
            let control2 = CGPoint(
              x: currentPoint.x,
              y: currentPoint.y - (lineHeight / 2 * controlFactor)
            )

            path.addCurve(to: currentPoint, control1: control1, control2: control2)
          }
        }
        .stroke(
          .ultraThinMaterial,
          style: StrokeStyle(
            lineWidth: lineWidth,
            lineCap: .round,
            lineJoin: .round
              // dash: [40, 25] // More dash spacing
          )
        )

        // Add views at alternating positions
        ForEach(views.indices, id: \.self) { index in
          let offsetX = spacing * (index % 2 == 0 ? 1 : -1)
          let offsetY = offsetYValues[index]  // pre-calculated offsetY value

          // Apply the inward offset to some points
          let inwardOffsetFactor: CGFloat =
            (index % variationIndex == variationIndex - 1) ? variationFactor : 1.0

          views[index]
            .frame(width: 50, height: 50)
            .position(x: centerX + offsetX * inwardOffsetFactor, y: offsetY)
        }
      }
      .frame(maxWidth: .infinity)  // Make sure the content is centered on the X-axis
      .padding(.horizontal, (geometry.size.width - availableWidth) / 2)  // Adjust padding to center
    }
  }
}
