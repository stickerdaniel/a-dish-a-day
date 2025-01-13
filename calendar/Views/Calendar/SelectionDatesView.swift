//
//  SelectionDatesView.swift
//  calendar
//
//  Created by Lucy May Plassmann on 12.01.25.
//

import SwiftUI

struct SelectionDatesView: View {
    let name: String
    @State var startDate: Date
    @State var endDate: Date
    @State var numberOfDays: Int
    @State var sameMonth: Bool = false
    

    //if(startDate.component())
    var body: some View {
        ScrollView(.vertical) {
            var columns = [GridItem(.adaptive(minimum: 100))]
            let startDay = dayFilter(date: startDate) ?? 0
            let endDay = dayFilter(date: endDate) ?? 0
            let month = Int(convertTimestamp(date: startDate).dropFirst(5).prefix(2))
            
           // .onAppear{checkMonth()}
            if sameMonth {
                let data = Array(startDay...endDay)
                LazyVGrid(columns: columns) {
                    ForEach(data, id: \.self) { item in
                        NumberGridItem(day: item)
                    }
                }
            } else if month == 2 {
                let data = Array(startDay...28) + Array(1...endDay)
                LazyVGrid(columns: columns) {
                    ForEach(data, id: \.self) { item in
                        NumberGridItem(day: item)
                    }
                }
            } else if month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12{
                let data = Array(startDay...31) + Array(1...endDay)
                LazyVGrid(columns: columns) {
                    ForEach(data, id: \.self) { item in
                        NumberGridItem(day: item)
                    }
                }
            } else {
                let data = Array(startDay...31) + Array(1...endDay)
                LazyVGrid(columns: columns) {
                    ForEach(data, id: \.self) { item in
                        NumberGridItem(day: item)
                    }
                }
            }
        }
        .onAppear{checkMonth()}
    }
    func convertTimestamp(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
    func checkMonth() {
            let start = convertTimestamp(date: startDate)
            let end = convertTimestamp(date: endDate)
            
            // Check if the months are the same
        if start.dropFirst(5).prefix(2) == end.dropFirst(5).prefix(2) {
                sameMonth = true
            }
        }
    func dayFilter(date: Date) -> Int? {
        let convertedDate = convertTimestamp(date: date)
        return Int(convertedDate.dropFirst(8).prefix(2))
    }
    
}

struct NumberGridItem: View {
    let day: Int
    var body: some View {
        Text(String(day))
            .padding()
            .frame(width: 100, height: 100)
            .overlay(
                RoundedRectangle(cornerRadius: 15.0)
                    .stroke(.black, lineWidth: 2.0)
            )
    }
}


#Preview {
   // SelectionDatesView()
}
