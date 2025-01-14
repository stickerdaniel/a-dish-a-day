//
//  EditRecipeView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/18.
//

import SwiftUI
import SwiftData

struct RecipeView: View {
    @Query private var recipes: [Recipe]
    var columns = [GridItem(.adaptive(minimum: 100))]
    @State private var isShowingSettings = false;
    var body: some View {
        LazyVGrid(columns: columns) {
            AddRecipeButton()
            ForEach(recipes, id: \.self) { r in
                RecipeGridItem(recipe: r)
            }
        }
        .padding(.leading,20)
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top, 20)
        .navigationTitle("Recipes")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Settings", systemImage: "gearshape") {
                    isShowingSettings.toggle()
                }
                .sheet(isPresented: $isShowingSettings) {
                    SettingsView()
                }
                .presentationDragIndicator(.visible)
            }
        }
        
    }
    struct AddRecipeButton: View {
        @State private var isShowingForm = false;
        var body: some View {
            Button("", systemImage: "plus") {
                isShowingForm.toggle()
            }

            .frame(width: 100, height: 100)
            .overlay(
                RoundedRectangle(cornerRadius: 15.0)
                    .stroke(.black, lineWidth: 2.0)
            )
            .sheet(isPresented: $isShowingForm) {
                AddRecipeView()
            }
        }
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

