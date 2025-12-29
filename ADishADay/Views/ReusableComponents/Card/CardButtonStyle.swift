//
//  CardButtonStyle.swift
//  A Dish A Day
//
//  Created by Daniel Sticker on 29.12.24.
//

import SwiftUI

struct CardButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .opacity(configuration.isPressed ? 0.5 : 1.0)
  }
}

extension ButtonStyle where Self == CardButtonStyle {
  static var card: CardButtonStyle { CardButtonStyle() }
}
