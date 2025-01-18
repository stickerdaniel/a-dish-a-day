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
    
    init(views: [Content], lineHeight: CGFloat = 200, maxWidth: CGFloat = 900) {
        self.views = views
        self.lineHeight = lineHeight
        self.maxWidth = maxWidth
    }
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = min(geometry.size.width, maxWidth) // Constrain to max width
            let spacing = availableWidth / 4 // Dynamically calculate spacing
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
                        let offsetY = CGFloat(index + 1) * lineHeight
                        
                        // Adjust control points dynamically based on available width
                        let previousPoint = CGPoint(
                            x: startX + (index > 0 ? spacing * ((index - 1) % 2 == 0 ? 1 : -1) : 0),
                            y: CGFloat(index) * lineHeight
                        )
                        
                        let currentPoint = CGPoint(x: startX + offsetX, y: offsetY)
                        
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
                        lineWidth: 6, // Thicker line
                        lineCap: .round,
                        lineJoin: .round,
                        dash: [20, 15] // More dash spacing
                    )
                )
                
                // Add views at alternating positions
                ForEach(views.indices, id: \.self) { index in
                    let offsetX = spacing * (index % 2 == 0 ? 1 : -1)
                    let offsetY = CGFloat(index + 1) * lineHeight
                    
                    views[index]
                        .frame(width: 50, height: 50)
                        .position(x: centerX + offsetX, y: offsetY)
                }
            }
            .frame(maxWidth: .infinity) // Make sure the content is centered on the X-axis
            .padding(.horizontal, (geometry.size.width - availableWidth) / 2) // Adjust padding to center
        }
    }
}
