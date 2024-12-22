//
//  DateView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/16.
//

import SwiftUI

struct DateRecipe: Hashable {
    var date: Date
    var recipe: Recipe
}

struct DateView: View {
    var calendar: CalendarModel
    var recipes: [DateRecipe]
    @State var selected = 0
    @State var path = NavigationPath()
    
    init(calendar: CalendarModel) {
        self.calendar = calendar
        self.recipes = []
        for (date, recipe) in (calendar.recipes.sorted{ $0.0 < $1.0}) {
            recipes.append(DateRecipe(date: date, recipe: recipe))
            
        }
        print(self.recipes)
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
                    ForEach(self.recipes.indices) { i in
                        CardView(recipe: self.recipes[i + selected].recipe, date: self.recipes[i + selected].date, path: $path)
                            .offset(x: CGFloat(i) * 20.0, y: CGFloat(i) * -20.0)
                            .zIndex(Double(-i))
                    }
                }
                .padding(.all, 8)
                Spacer()
                Text(String(selected))
//                ScrollBar(recipes: self.recipes)
            }
            
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    
                        
                }
            }
            .navigationDestination(for: DateRecipe.self) { r in
                DetailView(recipe: r.recipe, date: r.date)
            }
        }
    }
}

#Preview {
    NavigationView {
        DateView(calendar: CalendarModel.sampleCalendars[0])
    }
}
