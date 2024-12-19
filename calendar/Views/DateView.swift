//
//  DateView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/16.
//

import SwiftUI

struct DateView: View {
    var recipes: [Recipe]
    @State var selected = 0
    @State var path = NavigationPath()
    
    init() {
        self.recipes = Recipe.sampleRecipes
    }
    var body: some View {
        
        NavigationStack(path: $path) {
                
            VStack {
                Spacer()
                ZStack(alignment: .center) {
                    HStack {
                        Button(action: {() -> Void in self.selected = max(0, self.selected - 1) }) {
                            Label("Left", systemImage: "chevron.left")
                                .labelStyle(.iconOnly)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.circle)
                        .disabled(selected == 0)
                        Spacer()
                        Button(action: {() -> Void in self.selected = min(self.recipes.count - 1, selected + 1)}) {
                            
                            Label("Right", systemImage: "chevron.right")
                                .labelStyle(.iconOnly)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.circle)
                        .disabled(selected == self.recipes.count - 1)
                    }
                    .padding()
                    ForEach(0..<self.recipes.count - selected, id: \.self) { i in
                        RecipeView(recipe: self.recipes[i + selected], path: $path)
                            .offset(x: CGFloat(i) * 20.0, y: CGFloat(i) * -20.0)
                            .zIndex(Double(-i))
                    }
                }
                .padding(.all, 8)
                Spacer()
                Text(String(selected))
                ScrollBar(recipes: self.recipes)
            }
            
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    
                        
                    NavigationLink(destination: EditView())
                    {
                        Label("Menu", systemImage: "line.3.horizontal")
                    }
                }
            }
            .navigationDestination(for: Recipe.self) { r in
                DetailView(recipe: r)
            }
        }
    }
}

#Preview {
    NavigationView {
        DateView()
    }
}
