//
//  DetailView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/16.
//


import SwiftUI

struct DetailView: View {
    var recipe: Recipe
    var day: String
    var daySuffix: String
    
    init(recipe: Recipe) {
        self.recipe = recipe
        self.day = recipe.date.formatted(Date.FormatStyle().day(.defaultDigits))
        if (day == "1") {
            self.daySuffix = "st"
        } else if (day == "2") {
            self.daySuffix = "nd"
        } else if (day == "3") {
            self.daySuffix = "rd"
        } else {
            self.daySuffix = "th"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    
                    Text(self.day).font(.system(size: 52, weight: .black))
                    Text(self.daySuffix)
                }
                Spacer()
                Text(self.recipe.name)
                Spacer()
                
                
            }
            .padding(.bottom, 8)
            Text(self.recipe.description)
            Spacer()
        }
        .padding(.all, 40)
    }
}

#Preview {
    DetailView(recipe: Recipe.sampleRecipes[2])
}
