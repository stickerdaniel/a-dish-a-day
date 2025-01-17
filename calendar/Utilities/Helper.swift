//
//  Helper.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/16.
//

import SwiftUI

class Helper {
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func formatDate(_ date: Date) -> String {
        return formatter.string(from: date)
    }

    static func getDate(_ string: String) -> Date? {
        return formatter.date(from: string)
    }
    
    static func day(_ date: Date) -> String {
        date.formatted(Date.FormatStyle().day(.defaultDigits))
    }
    static func month(_ date: Date) -> String {
        date.formatted(Date.FormatStyle().month(.defaultDigits))
    }
    static func monthName(_ date: Date) -> String {
        date.formatted(Date.FormatStyle().month(.wide))
    }

    static func daySuffix(_ day: Int) -> String {
        
        switch(day) {
        case 1, 11, 21: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
}
