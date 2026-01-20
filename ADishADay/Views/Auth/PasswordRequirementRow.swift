//
//  PasswordRequirementRow.swift
//  A Dish A Day
//

import SwiftUI

/// A row displaying a password requirement with a checkmark/circle indicator.
struct PasswordRequirementRow: View {
  let text: String
  let isMet: Bool
  var indented: Bool = false

  var body: some View {
    HStack(spacing: 4) {
      if indented {
        Spacer().frame(width: 16)
      }
      Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
        .foregroundStyle(isMet ? .green : .secondary)
        .font(.caption2)

      Text(text)
        .font(.caption)
        .foregroundStyle(isMet ? .primary : .secondary)
    }
  }
}

#Preview("Met") {
  PasswordRequirementRow(text: "At least 8 characters", isMet: true)
    .padding()
}

#Preview("Not Met") {
  PasswordRequirementRow(text: "One uppercase letter", isMet: false)
    .padding()
}
