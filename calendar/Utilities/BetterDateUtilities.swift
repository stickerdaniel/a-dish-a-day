//
//  BetterDateUtilities.swift
//  calendar
//
//  Created by Daniel Sticker on 17.01.25.
//

import Foundation

extension Date {
    /// Returns the date at midnight, discarding time components.
    var midnight: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Enumerates every day from `self` up to (and including) `endDate`.
    /// Returns an array of daily `Date`s, each at midnight.
    func allDates(upTo endDate: Date) -> [Date] {
        var dates: [Date] = []
        let cal = Calendar.current
        
        // Make sure our range is valid
        guard self <= endDate else { return dates }
        
        // Start enumerating from the day before `self`, so that first enumerated date is `self`.
        cal.enumerateDates(
            startingAfter: self.midnight.addingTimeInterval(-1),
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) { date, _, stop in
            guard let d = date else { return }
            if d > endDate.midnight {
                stop = true
            } else {
                dates.append(d)
            }
        }
        return dates
    }
    
    /// Convenience for grabbing the "day of month" integer, e.g., 1–31.
    var dayOfMonth: Int {
        Calendar.current.component(.day, from: self)
    }
    
    /// Convenience for the month of this date (1 through 12).
    var month: Int {
        Calendar.current.component(.month, from: self)
    }
    
    /// Start of the current month. (We could also do `Calendar.current.dateInterval(of: .month, for: self)?.start`.)
    var startOfMonth: Date {
        guard let date = Calendar.current.date(from:
            Calendar.current.dateComponents([.year, .month], from: self))
        else {
            return self
        }
        return date
    }
    
    /// End of the current month. (One day before the start of next month.)
    var endOfMonth: Date {
        guard let date = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1),
                                               to: self.startOfMonth)
        else {
            return self
        }
        return date
    }
}
