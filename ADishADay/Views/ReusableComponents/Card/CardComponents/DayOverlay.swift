//
//  DayOverlay.swift
//  calendar
//
//  Created by Daniel Sticker on 15.01.25.
//

import SwiftUI

struct DayOverlay: View {
  let day: Int

  var body: some View {
    ZStack {
      Circle()
        .fill(.ultraThinMaterial)
        .frame(width: 72, height: 72)

      Text("\(day)")
        .font(.largeTitle)
        .fontWeight(.bold)
        .foregroundColor(.secondary)
    }
  }
}
