//
//  ScrollBar.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/16.
//


import SwiftUI

struct ScrollBar: View {
    
    private var diameter = 3.0
    var monthName: String
    var validDays: Set<Int>
    
    init (recipes: [Recipe]) {
        self.monthName = recipes[0].monthName
        validDays = Set(recipes.map { recipe in
            return Int(recipe.day) ?? 0
        })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(self.monthName).font(.caption)
            HStack {
                ForEach(1..<31, id:\.self) { i in
//                    Circle()
//                        .fill(validDays.contains(i) ? .blue : .gray)
//                        .frame(width: self.diameter, height: self.diameter)
                    Text(String(i % 10)).font(.system(size: 6))
                }
            }
        }.padding(.all, 8)
    }
}

#Preview {
    ScrollBar(recipes: Recipe.sampleRecipes)
}
