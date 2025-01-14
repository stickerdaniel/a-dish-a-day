//
//  CalendarGridView.swift
//  calendar
//
//  Created by Daniel Sticker on 14.01.25.
//

import SwiftUI

struct CalendarGridView: View {
    let calendars: [CalendarModel]
    let addButton: AnyView

    // flex wrap
    var columns = [GridItem(.adaptive(minimum: 112), spacing: 16)]

    var body: some View {
        ScrollView{
            LazyVGrid(columns: columns, spacing: 16) {
                addButton
                
                ForEach(calendars, id: \.self) { calendar in
                    CalendarGridItem(calendar: calendar)
                }
            }
            .padding()
            .padding(.top)
        }
    }
}
