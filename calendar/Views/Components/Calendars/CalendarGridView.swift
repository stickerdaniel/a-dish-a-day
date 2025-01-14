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

    var columns = [GridItem(.adaptive(minimum: 100))]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 32) {
            addButton

            ForEach(calendars, id: \.self) { calendar in
                CalendarGridItem(calendar: calendar)
            }
        }
        .padding()
        .padding(.top)
    }
}
