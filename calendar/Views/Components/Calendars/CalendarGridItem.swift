//
//  CalendarGridItem.swift
//  calendar
//
//  Created by Daniel Sticker on 14.01.25.
//

import SwiftUI

struct CalendarGridItem: View {
    var calendar: CalendarModel

    var body: some View {
        NavigationLink(destination: EditCalendarView(calendar: calendar)) {
            CalendarCard(
                image: calendar.thumbnailImage, // Computed property to handle thumbnail
                description: calendar.name
            )
        }
    }
}
