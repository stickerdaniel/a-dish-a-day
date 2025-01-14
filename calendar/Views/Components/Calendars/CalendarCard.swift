//
//  CalendarCard.swift
//  calendar
//
//  Created by Daniel Sticker on 14.01.25.
//
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
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if let icon = icon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.gray)
                } else if image != nil {
                    image?
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 130)
                        .clipped()
                } else {
                    Image("calendar-default-thumbnail") // Default fallback image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 130)
                        .clipped()
                }
            }
            .frame(width: 100, height: 130)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 2)
            .onTapGesture {
                action?()
            }

            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(height: 40, alignment: .top)
                .frame(maxWidth: 100)
        }
    }
}
