//
//  RecipesView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/18.
//

import SwiftUI
import SwiftData

struct RecipesView: View {
    @Query private var recipes: [RecipeModel]
    @State private var navigateToAddRecipe = false
    @State private var isShowingSettings = false
    @State private var navigationPath = NavigationPath() // Tracks navigation state

    var body: some View {
        NavigationStack(path: $navigationPath) {
            CardsView(
                items: recipes,
                addButton: AnyView(
                    Card(
                        icon: Image(systemName: "plus"),
                        description: "Create new Recipe"
                    )
                    .onTapGesture {
                        navigateToAddRecipe = true
                    }
                )
            ) { recipe in
                RecipeCard(recipe: recipe)
            }
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
                    .onDisappear {
                        refreshNavigationPath()
                    }
            }
            .navigationDestination(for: RecipeModel.self) { recipe in
                OpenRecipeView(recipe: recipe)
            }
        }
    }

    // MARK: - Helper

    /// Refreshes the navigation path to reflect data updates
    private func refreshNavigationPath() {
        navigationPath = NavigationPath() // Reset the navigation path
    }
}
