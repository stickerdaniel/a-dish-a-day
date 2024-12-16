//
//  Helper.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/16.
//

import SwiftUI

class Helper {
    static let formatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    static func getDate(_ d: String) -> Date {
        return self.formatter.date(from: d) ?? Date()
    }
}
