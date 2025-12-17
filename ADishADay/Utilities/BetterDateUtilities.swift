//
//  BetterDateUtilities.swift
//  calendar
//
//  Created by Daniel Sticker on 17.01.25.
//  custom extension for date utilities that we needed multiple times

import Foundation

extension Date {
  /// Returns the date at midnight, discarding time components.
  var midnight: Date {
    Calendar.current.startOfDay(for: self)
  }

  /// Enumerates every day from `self` up to (and including) `endDate`.
  func allDates(upTo endDate: Date) -> [Date] {
    var dates: [Date] = []
    let cal = Calendar.current

    guard self <= endDate else { return dates }

    cal.enumerateDates(
      startingAfter: self.midnight.addingTimeInterval(-1),
      matching: DateComponents(hour: 0, minute: 0, second: 0),
      matchingPolicy: .nextTime
    ) { date, _, stop in
      guard let currentDate = date else { return }
      if currentDate > endDate.midnight {
        stop = true
      } else {
        dates.append(currentDate)
      }
    }
    return dates
  }

  /// Convenience for grabbing the "day of month" integer, e.g., 1–31.
  var dayOfMonth: Int {
    Calendar.current.component(.day, from: self)
  }

  /// Start of the current month.
  var startOfMonth: Date {
    guard
      let date = Calendar.current.date(
        from:
          Calendar.current.dateComponents([.year, .month], from: self))
    else {
      return self
    }
    return date
  }

  /// End of the current month.
  var endOfMonth: Date {
    guard
      let date = Calendar.current.date(
        byAdding: DateComponents(month: 1, day: -1),
        to: self.startOfMonth)
    else {
      return self
    }
    return date
  }
}
