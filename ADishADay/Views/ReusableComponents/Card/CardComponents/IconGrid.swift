//
//  IconGrid.swift
//  calendar
//
//  Created by Daniel Sticker on 15.01.25.
//

import SwiftUI

struct IconGrid: View {
  var symbols: [String]  // List of SF Symbols

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        // Overlay Honeycomb
        HoneycombOverlay(symbols: symbols, cols: symbols.count * 3 / 2)
          .frame(
            width: geometry.size.width * 1.5,
            height: geometry.size.height * 1.5
          )
          .rotationEffect(.degrees(30))
          .offset(x: -geometry.size.width * 0.25, y: -geometry.size.height * 0.25)
      }
    }
  }
}

struct HoneycombOverlay: View {
  var symbols: [String]  // List of SF Symbols
  let cols: Int
  let spacing: CGFloat = 10
  let imgSize = CGSize(width: 24, height: 24)  // Size of each hexagon
  let imgSizeSmall = CGSize(width: 18, height: 18)  // Size of each 2nd hexagon

  var hexagonWidth: CGFloat { (imgSize.width / 2) * cos(.pi / 6) * 2 }

  var body: some View {
    let gridItems = Array(repeating: GridItem(.fixed(hexagonWidth), spacing: spacing), count: cols)

    LazyVGrid(columns: gridItems, spacing: spacing) {
      ForEach(0..<30) { idx in
        VStack(spacing: 0) {
          Image(systemName: symbols[idx % symbols.count])  // Repeat symbols
            .resizable()
            .scaledToFit()
            .frame(
              width: isBigIcon(idx) ? imgSize.width : imgSizeSmall.width,
              height: isBigIcon(idx) ? imgSize.height : imgSizeSmall.height
            )
            .rotationEffect(.degrees(-30))
            .offset(x: isEvenRow(idx) ? 0 : hexagonWidth / 2 + (spacing / 2))
            .foregroundColor(.cardIcon)
        }
        .frame(width: hexagonWidth, height: imgSize.height * 0.75)
      }
    }
    .frame(width: (hexagonWidth + spacing) * CGFloat(cols - 1))
  }

  func isEvenRow(_ idx: Int) -> Bool { (idx / cols) % 2 == 0 }
  // ad some variety to break up the pattern
  func isBigIcon(_ idx: Int) -> Bool { idx % (symbols.count / 2) == 0 }
}

struct PolygonShape: Shape {
  let sides: Int

  func path(in rect: CGRect) -> Path {
    guard sides > 2 else { return Path() }
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let radius = min(rect.width, rect.height) / 2
    let angle = (2 * .pi) / CGFloat(sides)

    var path = Path()
    path.move(to: CGPoint(x: center.x + radius * cos(0), y: center.y + radius * sin(0)))

    for i in 1..<sides {
      let x = center.x + radius * cos(angle * CGFloat(i))
      let y = center.y + radius * sin(angle * CGFloat(i))
      path.addLine(to: CGPoint(x: x, y: y))
    }

    path.closeSubpath()
    return path
  }
}
