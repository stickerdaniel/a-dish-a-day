//
//  RecipesView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/18.
//

import SwiftData
import SwiftUI

struct RecipesView: View {
  @ObserveInjection var inject
  @Query private var recipes: [RecipeModel]
  @State private var isShowingSettings = false

  var body: some View {
    NavigationStack {
      CardsView(
        items: recipes,
        addButton: AnyView(
          NavigationLink(destination: EditRecipeView()) {
            Card(
              icon: Image(systemName: "plus"),
              description: "Create new Recipe"
            )
          }
        )
      ) { recipe in
        RecipeCard(recipe: recipe)
      }
      .navigationTitle("Recipes")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            isShowingSettings = true
          } label: {
            Image(systemName: "gearshape")
          }
        }
      }
      .fullScreenCover(isPresented: $isShowingSettings) {
        NavigationStack {
          SettingsView()
            .toolbar {
              ToolbarItem(placement: .topBarTrailing) {
                Button {
                  isShowingSettings = false
                } label: {
                  Image(systemName: "xmark")
                }
              }
            }
        }
      }
    }
    .enableInjection()
  }
}
