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
    
    @State private var changedNumberOfDays = false
    @State private var navigateToSelection = false
    
    
    
    func updateNumberOfDays() {

        changedNumberOfDays = true
        let newNumberOfDays = Calendar.current.dateComponents([.day], from: startDate, to: endDate)
        if let days = newNumberOfDays.day {
            numberOfDays = days + 1
        }
    }

    var body: some View {
            NavigationStack {
                Form {
                    Section {
                        TextField("Name", text: $name)
                    }

                    Section {
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
                                .onChange(of: numberOfDays) {
                                    guard !changedNumberOfDays else {
                                        changedNumberOfDays = false
                                        return
                                    }
                                    if let futureDate = Calendar.current.date(byAdding: .day, value: numberOfDays, to: startDate) {
                                        endDate = futureDate
                                    }
                                }
                        }
                    }
                }
                .navigationTitle("Add Calendar")
                
                Button("Add Calendar") {
                    navigateToSelection = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.bottom, 10)

                // NavigationLink controlled by the @State variable
                NavigationLink(
                    destination: SelectionDatesView(name: name, startDate: startDate, endDate: endDate, numberOfDays: numberOfDays),
                    isActive: $navigateToSelection
                ) {
                    EmptyView()
                }
            }
        }
}



#Preview {
    AddCalendarView()
}
