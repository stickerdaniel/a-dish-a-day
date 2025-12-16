//
//  RecipesView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/18.
//

import SwiftUI
import SwiftData

import SwiftUI
import SwiftData

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
                        isShowingSettings.toggle()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .sheet(isPresented: $isShowingSettings) {
                        SettingsView()
                    }
                }
            }
        }
        .enableInjection()
    }
}
