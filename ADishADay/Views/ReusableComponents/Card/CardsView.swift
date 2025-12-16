//
//  CardsView.swift
//  calendar
//
//  Created by Daniel Sticker on 14.01.25.
//

import SwiftUI

/// Used by CalendarsView and RecipesView
struct CardsView<Item: Identifiable & Hashable, Content: View, Header: View>: View {
  /// The array of items to display in the grid
  let items: [Item]

  /// A view representing the add button
  let addButton: AnyView

  /// View builder for each grid item
  let content: (Item) -> Content

  /// An optional header view
  @ViewBuilder var header: () -> Header

  var body: some View {
    ScrollView {
      // Optional header
      header()

      let columns = [GridItem(.adaptive(minimum: Card.minimumWidth), spacing: Card.spacing)]

      LazyVGrid(columns: columns, spacing: Card.spacing) {
        addButton

        ForEach(items, id: \.self) { item in
          content(item)
        }
      }
      .padding()
    }
  }

  /// Initializer for custom header or default empty header
  init(
    items: [Item],
    addButton: AnyView,
    @ViewBuilder header: @escaping () -> Header = { EmptyView() },  // Default to no header
    @ViewBuilder content: @escaping (Item) -> Content
  ) {
    self.items = items
    self.addButton = addButton
    self.header = header
    self.content = content
  }
}
