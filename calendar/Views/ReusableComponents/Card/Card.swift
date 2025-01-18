import SwiftUI

enum BadgeType {
    case none
    case indicator // Red dot indicator
    case warning   // Warning triangle
}

struct Card: View {
    var image: Image? = nil // Optional image
    var icon: Image? = nil // Optional icon
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
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.yellow)
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
