//
//  CreatedCalendarView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/20.
//
import SwiftData

import SwiftUI

struct AddCalendarButton: View {
    @State var isShowingForm = false
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
            AddCalendarView(isShowingForm: $isShowingForm)
        }
    }
}

struct CalendarGridItem: View {
    var calendar: CalendarModel
    var body: some View {
        NavigationLink(destination: EditCalendarView(calendar: calendar)) {
            
            Text(calendar.name)
                .padding()
                .frame(width: 100, height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 15.0)
                        .stroke(.black, lineWidth: 2.0)
                )
        }
    }
}

struct CreatedCalendarView: View {
    @Query private var calendars: [CalendarModel]
    var columns = [GridItem(.adaptive(minimum: 100))]
    
    var body: some View {
        LazyVGrid(columns: columns) {
            AddCalendarButton()
            ForEach(calendars, id: \.self) { c in
                CalendarGridItem(calendar: c)
            }
        }
        .padding(.leading,20)
    }
}

#Preview() {
    CreatedCalendarView()
}
