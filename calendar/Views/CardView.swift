//
//  RecipeView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/16.
//

import SwiftUI

struct CardView: View {
    
    var recipe: Recipe
    var date: Date
    @Binding var path: NavigationPath
    
    var body: some View {
            VStack(alignment: .leading) {
                
                Text(Helper.day(date))
                    .font(.system(size: 40, weight: .black))
                Button(action: {() in path.append(DateRecipe(date: date, recipe: recipe))}) {
                        Text("See Recipe")
                            .padding()
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                            
                    }
                    
                
            }
            .frame(width: 200, height: 300)
            .padding(.all, 40)
            .cornerRadius(24)
            .background(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.black, lineWidth: 2)
            )
            .padding(.all, 40)
    }
}
#Preview {
    
//    RecipeView(recipe: Recipe.sampleRecipes[2], path: NavigationPath())
}
