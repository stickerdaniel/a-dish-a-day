//
//  Cards.swift
//  calendar
//
//  Created by Daniel Sticker on 14.01.25.
//

import SwiftUI

enum BadgeType {
    case none
    case indicator // Red dot indicator
    case warning   // Warning triangle
    case locked    // Locked symbol
}

struct Card: View {
    var image: Image? = nil // Optional image
    var icon: Image? = nil // Optional icon
    var blurred: Bool = false // Optional blurr
    var badgeType: BadgeType = .none // Badge type
    var description: String
    var fallbackSymbols: [String] = [] // Pass SF Symbols for the grid
    var day: Int? = nil // Optional day to display as overlay
    
    static let minimumWidth: CGFloat = 96
    static let spacing: CGFloat = 16

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cardBackground)
                    .overlay(
                        ZStack {
                            if let image = image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                            } else if let icon = icon {
                                icon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.gray)
                            } else if !fallbackSymbols.isEmpty {
                                IconGrid(symbols: fallbackSymbols)
                                if blurred {
                                    Rectangle() // black overlay
                                        .fill(Color.black.opacity(0.4))
                                }
                            }
                            
                            if blurred {
                                Rectangle()
                                    .fill(.ultraThinMaterial)
                            }

                            if let day = day {
                                DayOverlay(day: day)
                            }
                        }
                    )
                    .frame(height: 144)
                    .cornerRadius(16)
                    .clipped()
                    .shadow(radius: 2)

                // Display badge based on `badgeType`
                badgeView
                    .offset(x: 5, y: -5)
            }

            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .frame(height: 40, alignment: .top)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var badgeView: some View {
        switch badgeType {
        case .none:
            EmptyView()
        case .indicator:
            Circle()
                .fill(Color.red)
                .frame(width: 20, height: 20)
        case .warning:
            Circle()
                .frame(width: 24, height: 24)
                .foregroundColor(.yellow)
                .overlay(
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .foregroundColor(Color(.systemBackground))
                        .offset(y: -1)
                )


        case .locked:
            Image(systemName: "lock.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.secondary)
                .background(Color(UIColor.systemBackground))
                .clipShape(Circle())
        }
    }
}

// Extension for dynamic card background color
extension Color {
    static var cardBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
            ? UIColor.secondarySystemBackground.withAlphaComponent(0.75)
            : .systemBackground
        })
    }
    static var cardIcon: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
            ? .gray.withAlphaComponent(0.75)
            : UIColor.secondarySystemBackground
        })
    }
}
