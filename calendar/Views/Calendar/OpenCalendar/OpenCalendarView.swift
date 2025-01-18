//
//  OpenCalendarView.swift
//  calendar
//
//  Created by Daniel Sticker on 18.01.25.
//

import SwiftUI

struct OpenCalendarView: View {
    var calendar: CalendarModel
    var day: Int? = nil // Optional day to display

    var body: some View {
        ScrollView {

        }
        .frame(maxWidth: .infinity) // Ensure full width
        .navigationTitle("Calendar Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
