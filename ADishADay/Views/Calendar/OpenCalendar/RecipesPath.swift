//
//  RecipesPath.swift
//  calendar
//
//  Created by Daniel Sticker on 18.01.25.
//  Here we generate a calendar-unique path and pass the recipe doors 

import SwiftUI

struct RecipesPath<Content: View>: View {
    let views: [Content]
    let seed: Int
    let lineHeight: CGFloat
    let maxLineHeightVariation: CGFloat

    init(views: [Content], seed: Int, lineHeight: CGFloat = 200, maxLineHeightVariation: CGFloat = 50) {
        self.views = views
        self.seed = seed
        self.lineHeight = lineHeight
        self.maxLineHeightVariation = maxLineHeightVariation
    }

    var body: some View {
        ZStack {
            // Generate the offsetY values based on the seed
            var rng = SeededRandomNumberGenerator(seed: seed)
            let offsetYValues: [CGFloat] = (0..<views.count).map { index in
                let baseOffsetY = CGFloat(index + 1) * lineHeight
                
                // Use the random number generator to calculate variation
                // Random number between -1 and 1
                var randomVariation = CGFloat(rng.next()) * 2.0 - 1.0
                
                // reduce rando variation for first
                if index == 0 {
                    randomVariation = randomVariation / 2
                }
                
                return baseOffsetY + (randomVariation * maxLineHeightVariation)
            }

            // Pass calculated offsetYValues and views to ZigZagLineView
            ZigZagLineView(
                offsetYValues: offsetYValues,
                views: views
            )
            .frame(maxWidth: .infinity)  // Ensure full width
            
            Rectangle().opacity(0).frame(height: (offsetYValues.last ?? 0) + 384 ) // Spacer to ensure full height
        }
    }
}
