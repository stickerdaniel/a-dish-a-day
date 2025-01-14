//
//  OpenRecipeView.swift
//  calendar
//
//  Created by Lucy May Plassmann on 12.01.25.
//


import SwiftUI

struct OpenRecipeView: View{
    var recipe: Recipe
    
    init(recipe: Recipe) {
        self.recipe = recipe
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                Spacer()
                Text(self.recipe.name)
                Spacer()
                
                
            }
            .padding(.bottom, 8)
            Text(self.recipe.text)
            Spacer()
        }
        .padding(.all, 40)
    }
}

