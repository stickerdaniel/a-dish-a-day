//
//  DatePickerRange.swift
//  calendar
//  Doesn't work, don't use it
//  Created by Vincent Nahn on 2024/12/20.
//

import SwiftUI

extension DateComponents: Comparable {
    public static func < (lhs: DateComponents, rhs: DateComponents) -> Bool {
        let now = Date()
        let calendar = Calendar.current
        return calendar.date(byAdding: lhs, to: now)! < calendar.date(byAdding: rhs, to: now)!
    }
}

struct DatePickerRange: View {
    @State private var dates: Set<DateComponents> = []
    var body: some View {
        
//        Text(dates.first)
        
        MultiDatePicker("Calendar dates", selection: $dates)
            .onChange(of: dates) { oldDates, newDates in
                if newDates.count == 2 && oldDates.count < newDates.count {
                    let newDate = newDates.subtracting(oldDates).first!
                    let oldDate = oldDates.first!
                    if newDate < oldDate {
                        print(newDate)
                        dates = [newDate]
                    }
                    
                } else if newDates.count > 2 {
                    let newDate = newDates.subtracting(oldDates).first!
                    dates = [newDate]
                    
                }
            }
    }
}

#Preview {
    DatePickerRange()
}
