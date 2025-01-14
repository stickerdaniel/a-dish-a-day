//
//  CalendarCard.swift
//  calendar
//
//  Created by Daniel Sticker on 14.01.25.
//

import SwiftUI

struct CalendarCard: View {
    var image: Image? = nil // Optional image
    var icon: Image? = nil // Optional icon
    var description: String
    
    
    // systemBackground for lightmode, secondarySystemBackground for darkmode

    var body: some View {
        VStack(spacing: 8) {
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
                // light opacity for dark mode
            ? UIColor.secondarySystemBackground.withAlphaComponent(0.5)
                : .systemBackground
        })
    }
}
