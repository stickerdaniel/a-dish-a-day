//
//  RecipeView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/18.
//

import SwiftUI
import SwiftData

struct RecipeView: View {
    @Query private var recipes: [RecipeModel]
    @State private var navigateToAddRecipe = false // Trigger for adding a recipe
    @State private var isShowingSettings = false

    var body: some View {
        NavigationStack {
            RecipeGridView(
                recipes: recipes,
                addButton: AnyView(
                    Card(
                        icon: Image(systemName: "plus"),
                        description: "Create new Recipe"
                    )
                    .onTapGesture {
                        navigateToAddRecipe = true
                    }
                )
            )
            .navigationTitle("Recipes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingSettings.toggle()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .sheet(isPresented: $isShowingSettings) {
                        SettingsView()
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToAddRecipe) {
                EditRecipeView()
            }
        }
    }
}
