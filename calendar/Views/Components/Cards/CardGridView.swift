//
//  CardGridView.swift
//  calendar
//
//  Created by Daniel Sticker on 14.01.25.
//

import SwiftUI

struct CardGridView<Item: Identifiable & Hashable, Content: View>: View {
    let items: [Item] // Items to display in the grid
    let addButton: AnyView // Optional add button
    let content: (Item) -> Content // View builder for each grid item

    // Flex wrap columns
    var columns = [GridItem(.adaptive(minimum: 112), spacing: 16)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                addButton

                ForEach(items, id: \.self) { item in
                    content(item)
                }
            }
            .padding()
            .padding(.top)
        }
    }
}
