//
//  CardGridView.swift
//  calendar
//
//  Created by Daniel Sticker on 14.01.25.
//

import SwiftUI

struct CardGridView<Item: Identifiable & Hashable, Content: View, Header: View>: View {
    let items: [Item] // Items to display in the grid
    let addButton: AnyView // Optional add button
    let content: (Item) -> Content // View builder for each grid item
    @ViewBuilder var header: () -> Header // Optional header view

    // Flex wrap columns
    var columns = [GridItem(.adaptive(minimum: 96), spacing: 16)]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header()
                LazyVGrid(columns: columns, spacing: 16) {
                    addButton

                    ForEach(items, id: \.self) { item in
                        content(item)
                    }
                }
            }
            .padding()
        }
    }

    init(
        items: [Item],
        addButton: AnyView,
        @ViewBuilder header: @escaping () -> Header = { EmptyView() }, // Default to no header
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.addButton = addButton
        self.header = header
        self.content = content
    }
}
