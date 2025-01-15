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
    /// - Returns: `URL` pointing to  JSON file
    static func encodeCalendar(_ calendar: CalendarModel) -> URL? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(calendar)
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
            return calendar
        } catch {
            print("Error decoding calendar: \(error)")
            return nil
        }
    }
}
