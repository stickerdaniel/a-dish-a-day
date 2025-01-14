//
//  DetailView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/16.
//


import SwiftUI

struct DetailView: View {
    var recipe: RecipeModel
    var day: String
    var daySuffix: String
    var date: Date
    
    init(recipe: RecipeModel, date: Date) {
        self.date = date
        self.recipe = recipe
        self.day = Helper.day(date)
        self.daySuffix = Helper.daySuffix(Int(self.day) ?? 0)
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
            Text(self.recipe.text)
            Spacer()
        }
        .padding(.all, 40)
    }
}

