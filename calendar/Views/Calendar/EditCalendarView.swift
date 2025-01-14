//
//  EditCalendar.swift
//  calendar
//
//  Created by Vincent Nahn on 2025/1/12.
//

import SwiftUI

struct EditCalendarView: View {
    var calendar: CalendarModel
    var formatter: DateFormatter
    
    init(calendar: CalendarModel) {
        self.calendar = calendar
        self.formatter = DateFormatter()
        self.formatter.dateStyle = .medium
        self.formatter.timeStyle = .none
    }

    
    var body: some View {
        List {
            ForEach(0..<calendar.daysBetween, id: \.self) {i in
                if let newDate = Calendar.current.date(byAdding: .day, value: i, to: calendar.startDate) {
                    Text(formatter.string( from: newDate) )
                } else {
                    Text("Wrong date format")
                }
            }
        }
    }
}
