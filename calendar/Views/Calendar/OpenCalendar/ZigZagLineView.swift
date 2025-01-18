//
//  ZigZagLineView.swift
//  calendar
//
//  Created by Daniel Sticker on 18.01.25.
//

import SwiftUI

struct ZigZagLineView<Content: View>: View {
    let views: [Content]
    let lineHeight: CGFloat
    let maxWidth: CGFloat
    
    let variationIndex: Int = 3
    let variationFactor: CGFloat = 0.6
    let variationIndexY: Int = 4
    let variationFactorY: CGFloat = 0.8
    let variationFactorYLineHeight: CGFloat = 0.9
    
    init(views: [Content], lineHeight: CGFloat = 200, maxWidth: CGFloat = 900) {
        self.views = views
        self.lineHeight = lineHeight
        self.maxWidth = maxWidth
    }
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = min(geometry.size.width, maxWidth) // Constrain to max width
            let spacing = availableWidth / 3.5 // Dynamically calculate spacing
            let centerX = availableWidth / 2 // Center of the screen
            
            ZStack {
                // Draw the bezier path as a dashed line
                Path { path in
                    let startX = centerX // Start from the middle
                    let startY: CGFloat = 0
                    
                    path.move(to: CGPoint(x: startX, y: startY))
                    
                    for index in 0..<views.count {
                        // Dynamically calculate horizontal offset
                        let offsetX = spacing * (index % 2 == 0 ? 1 : -1)
                        let lineHeightFactor = (index % variationIndexY == 0) ? variationFactorYLineHeight : 1.0
                        let offsetY = CGFloat(index + 1) * lineHeight * lineHeightFactor
                        
                        // Introduce variation based on index (every other point or pattern-based)
                        let inwardOffsetFactor: CGFloat = (index % variationIndex == variationIndex-1) ? variationFactor : 1.0
                        
                        let yOffsetFactor: CGFloat = (index % variationIndexY == 0) ? variationFactorY : 1.0
                        
                        // Adjust control points dynamically based on available width
                        let previousPoint = CGPoint(
                            x: startX + (index > 0 ? spacing * ((index - 1) % 2 == 0 ? 1 : -1) : 0),
                            y: CGFloat(index) * lineHeight
                        )
                        
                        let currentPoint = CGPoint(x: startX + offsetX * inwardOffsetFactor, y: offsetY * yOffsetFactor)
                        
                        // Dynamic control points based on available width
                        let controlFactor: CGFloat = availableWidth / 450 // Factor that increases as width increases
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
                    Color(.secondaryLabel), // Dynamic background color
                    style: StrokeStyle(
                        lineWidth: 10, // Thicker line
                        lineCap: .round,
                        lineJoin: .round,
                        dash: [40, 25] // More dash spacing
                    )
                )
                
                // Add views at alternating positions
                ForEach(views.indices, id: \.self) { index in
                    let offsetX = spacing * (index % 2 == 0 ? 1 : -1)
                    let lineHeightFactor = (index % variationIndexY == 0) ? variationFactorYLineHeight : 1.0
                    let offsetY = CGFloat(index + 1) * lineHeight * lineHeightFactor
                    
                    // Apply the inward offset to some points
                    let inwardOffsetFactor: CGFloat = (index % variationIndex == variationIndex-1) ? variationFactor : 1.0
                    
                    let yOffsetFactor: CGFloat = (index % variationIndexY == 0) ? variationFactorY : 1.0
                    views[index]
                        .frame(width: 50, height: 50)
                        .position(x: centerX + offsetX * inwardOffsetFactor, y: offsetY * yOffsetFactor)
                }
            }
            .frame(maxWidth: .infinity) // Make sure the content is centered on the X-axis
            .padding(.horizontal, (geometry.size.width - availableWidth) / 2) // Adjust padding to center
        }
    }
}
