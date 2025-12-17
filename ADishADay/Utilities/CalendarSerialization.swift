//
//  CalendarSerialization.swift
//  calendar
//
//  Created by Daniel Sticker on 14.01.25.
//  This is needed to import a calendar and export it as a JSON file.

import Foundation
import UniformTypeIdentifiers

class CalendarSerialization {
  static let customCalendarFileExtension = "ddcal"

  /// Encodes a `CalendarModel` into a JSON file
  /// - Parameter calendar: `CalendarModel` to encode
  /// - Returns: `URL` pointing to JSON file
  static func encodeCalendar(_ calendar: CalendarModel) -> URL? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted

    // copy of the calendar to reset `hasBeenOpened` for all recipes while keeping calendar recipes state as is
    let calendarCopy = CalendarModel.copy(from: calendar)
    calendarCopy.recipes = calendarCopy.recipes.map { recipe in
      var modifiedRecipe = recipe
      modifiedRecipe.hasBeenOpened = false
      return modifiedRecipe
    }

    do {
      let data = try encoder.encode(calendarCopy)
      let fileName = "\(calendar.name).\(customCalendarFileExtension)"
      let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
      try data.write(to: fileURL)
      return fileURL
    } catch {
      return nil
    }
  }

  /// Decodes a JSON file into a `CalendarModel`
  /// - Parameter fileURL: `URL` of the JSON file.
  /// - Returns: decoded `CalendarModel` instance / nil if decoding failed
  static func decodeCalendar(from fileURL: URL) -> CalendarModel? {
    let decoder = JSONDecoder()
    do {
      let data = try Data(contentsOf: fileURL)
      let calendar = try decoder.decode(CalendarModel.self, from: data)
      if calendar.adjustDatesOnImport {
        // Adjust dates for imported calendar
        calendar.adjustDatesToCurrent()
      }
      return calendar
    } catch {
      return nil
    }
  }
}

extension UTType {
  static let customcalendar =
    UTType(filenameExtension: CalendarSerialization.customCalendarFileExtension) ?? UTType.text
}
