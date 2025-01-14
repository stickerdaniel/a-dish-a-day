//
//  CreatedCalendarView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/20.
//

import SwiftUI
import SwiftData

struct CreatedCalendarView: View {
    @Query private var calendars: [CalendarModel]
    @State private var isShowingForm = false

    var body: some View {
        CalendarGridView(
            calendars: calendars,
            addButton: AnyView(
                Card(
                    icon: Image(systemName: "plus"),
                    description: "Create new calendar"
                )
                .onTapGesture {
                    isShowingForm.toggle()
                }
                .sheet(isPresented: $isShowingForm) {
                    AddCalendarView(isShowingForm: $isShowingForm)
                }
            )
        )
    }
}

#Preview() {
    CreatedCalendarView()
}
