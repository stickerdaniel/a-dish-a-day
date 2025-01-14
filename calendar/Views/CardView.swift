//
//  RecipeView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/16.
//

import SwiftUI

struct CardView: View {
    
    var recipe: RecipeModel
    var date: Date
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(Helper.day(date))
                .font(.system(size: 40, weight: .black))
            NavigationLink {
                DetailView(recipe: recipe, date: date)
            } label: {
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
