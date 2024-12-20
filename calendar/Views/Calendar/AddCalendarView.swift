//
//  AddCalendarView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/18.
//

import SwiftUI

struct AddCalendarView: View {
    
    @State private var name = ""
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var numberOfDays = 0
    
//    let dateRange: ClosedRange<Date> = {
//        let calendar = Calendar.current
//        let startComponents = DateComponents(
//    }

    var body: some View {
        Form {
            Section() {
                TextField("Name", text: $name)
            }
            
            Section() {
                DatePicker("Start date", selection: $startDate, displayedComponents: .date)
                DatePicker("End date", selection: $endDate, in: startDate..., displayedComponents: .date)
                HStack {
                    
                    Text("Number of days")
                    Spacer()
                        
                    TextField("", value: $numberOfDays, format: .number)
                    .fixedSize()
                    .onChange(
                    
                }
            }
        }
    }
}



#Preview {
    AddCalendarView()
}
