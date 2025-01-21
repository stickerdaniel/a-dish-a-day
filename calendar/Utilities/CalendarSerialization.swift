//
//  CalendarSerialization.swift
//  calendar
//
//  Created by Daniel Sticker on 14.01.25.
//

import Foundation

class CalendarSerialization {
    
    /// Encodes a `CalendarModel` into a JSON file
    /// - Parameter calendar: `CalendarModel` to encode
    /// - Returns: `URL` pointing to JSON file
    static func encodeCalendar(_ calendar: CalendarModel, resetStartDate: Bool = true) -> URL? {
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
            let fileName = "\(calendar.name).json"
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            try data.write(to: fileURL)
            
            // Debug: Print JSON and file URL
            print("Exported JSON:\n", String(data: data, encoding: .utf8) ?? "Invalid JSON")
            print("File URL:", fileURL.path)
            
            return fileURL
        } catch {
            print("Error encoding calendar: \(error)")
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
            if(calendar.adjustDatesOnImport) {
                // Adjust dates for imported calendar
                calendar.adjustDatesToCurrent()
            }
            return calendar
        } catch {
            print("Error decoding calendar: \(error)")
            print("File path: \(fileURL.path)")
            return nil
        }
    }
}
