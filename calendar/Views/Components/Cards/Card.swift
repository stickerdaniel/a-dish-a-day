//
//  CalendarCard.swift
//  calendar
//
//  Created by Daniel Sticker on 14.01.25.
//

import SwiftUI

struct Card: View {
    var image: Image? = nil // Optional image
    var icon: Image? = nil // Optional icon
    var showBadge: Bool = false // Optional red badge if new recipe is available to unlock
    var description: String
    
    // systemBackground for lightmode, secondarySystemBackground for darkmode

    var body: some View {
        VStack(spacing: 8) {
            // alignment bottom trailing
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cardBackground) // Dynamically adjust based on color scheme
                    .overlay(
                        ZStack {
                            if let icon = icon {
                                icon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.gray)
                            } else if let image = image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                            } else {
                                Image("calendar-default-thumbnail") // Default fallback image
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                            }
                        }
                    )
                    .frame(height: 144)
                    .cornerRadius(16)
                    .clipped()
                    .shadow(radius: 2)
                
                // red badge if there is a new recipe to unlock
                if showBadge {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 20, height: 20)
                        .offset(x: 5, y: -5)
                }
            }
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity) // Ensure text stretches across the card width
                .frame(height: 40, alignment: .top)
        }
        .frame(maxWidth: .infinity) // Adapt to grid column width
    }
}

// Extension dynamic card bg color
extension Color {
    static var cardBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
            // light opacity for better dark mode visibility
            ? UIColor.secondarySystemBackground.withAlphaComponent(0.75)
                : .systemBackground
        })
    }
}
