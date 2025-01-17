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

    var body: some View {
        CardGridView(
            items: calendars,
            addButton: addButton
        ) { calendar in
            CalendarGridItem(calendar: calendar)
        }
    }
}
