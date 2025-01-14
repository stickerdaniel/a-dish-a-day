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
    @State private var isShowingAddRecipe = false
    @State private var isShowingSettings = false

    var body: some View {
        RecipeGridView(
            recipes: recipes,
            addButton: AnyView(
                Card(
                    icon: Image(systemName: "plus"),
                    description: "Create new Recipe"
                )
                .onTapGesture {
                    isShowingAddRecipe.toggle()
                }
                .sheet(isPresented: $isShowingAddRecipe) {
                    AddRecipeView()
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
    }
}
