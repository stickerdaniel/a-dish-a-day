//
//  AddCalendarView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/18.
//

import SwiftUI

struct AddCalendarView: View {
    
    @Binding var isShowingForm: Bool
    
    @State private var name = ""
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var numberOfDays = 1
    
    @Environment(\.modelContext) private var context

    func updateNumberOfDays() {

        let daysBetween = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day
        numberOfDays = (daysBetween ?? 0) + 1
    }

    var body: some View {
                

        NavigationStack {
            Form {
                Section() {
                    TextField("Name", text: $name)
                }
                
                Section() {
                    DatePicker("Starts", selection: $startDate, displayedComponents: .date)
                    DatePicker("Ends", selection: $endDate, in: startDate..., displayedComponents: .date)
                    HStack {
                        
                        Text("Number of days")
                        Spacer()
                        
                        TextField("", value: $numberOfDays, format: .number)
                            .fixedSize()
                            .onChange(of: startDate) {
                                
                                updateNumberOfDays()
                            }
                            .onChange(of: endDate) {
                                updateNumberOfDays()
                            }
                            .disabled(true)
                        
                    }
                }
                Section() {
                    
                    Button("Add new calendar") {
                        context.insert(CalendarModel(name: name, startDate: startDate, endDate: endDate))
                        isShowingForm = false
                    }
                    .disabled(name.isEmpty)
                }
            }
            .navigationTitle("Add Calendar")
            .presentationDragIndicator(.visible)
        }
    }
}
