//
//  DiplayRecipeDataView.swift
//  calendar
//
//  Created by Lucy May Plassmann on 12.01.25.
//  A reusable component for displaying recipe data used by the OpenCalendarRecipeView and OpenRecipeView.

import SwiftUI

struct DisplayRecipeDataView: View {
  var thumbnailImage: Image? = nil  // Optional thumbnail image
  var name: String = "Recipe Name"  // Recipe name
  var ingredients: String = "Ingredients"  // Ingredients list
  var steps: String = "Instructions"  // Recipe steps
  var day: Int? = nil  // Optional day to display

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        ZStack(alignment: .bottomLeading) {
          // Expand thumbnail image full width
          if let thumbnail = thumbnailImage {
            thumbnail
              .resizable()
              .scaledToFill()
              .frame(maxWidth: UIScreen.main.bounds.width)
              .frame(height: 200)
              .clipped()
              .cornerRadius(16)
              .shadow(radius: 4)

          }
          if let day = day {
            DayOverlay(day: day)
              .padding(16)
              .frame(maxWidth: .infinity, alignment: .leading)  // Centered overlay
          }
        }

        VStack(alignment: .leading, spacing: 16) {
          // Recipe Name
          Text(name)
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.primary)
            .padding(.bottom, 16)

          // Ingredients Section
          VStack(alignment: .leading, spacing: 8) {
            Text("Ingredients")
              .font(.headline)
              .foregroundColor(.secondary)

            Text(ingredients)
              .font(.body)
              .foregroundColor(.primary)
          }

          // Instructions Section
          VStack(alignment: .leading, spacing: 8) {
            Text("Instructions")
              .font(.headline)
              .foregroundColor(.secondary)

            Text(steps)
              .font(.body)
              .foregroundColor(.primary)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
      }
    }
    .frame(maxWidth: .infinity)  // Ensure full width
    .navigationTitle(name)
    .navigationBarTitleDisplayMode(.inline)
  }
}
