//
//  EditRecipeView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/18.
//

import SwiftUI

struct RecipeView: View {
    var recipes = Recipe.sampleRecipes
    var columns = [GridItem(.adaptive(minimum: 100))]
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(recipes, id: \.self) { r in
                RecipeGridItem(recipe: r)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top, 20)
        .navigationTitle("Recipes")
        
    }
    
    struct RecipeGridItem: View {
        var recipe: Recipe
        var body: some View {
            NavigationLink(destination: OpenRecipeView(recipe: recipe)) {
                
                Text(recipe.name)
                    .padding()
                    .frame(width: 100, height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15.0)
                            .stroke(.black, lineWidth: 2.0)
                    )
                }
            }
        }
    }
    
    #Preview {
        RecipeView()
    }

