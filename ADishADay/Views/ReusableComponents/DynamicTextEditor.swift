//
//  DynamicTextEditor.swift
//  calendar
//
//  Created by Daniel Sticker on 14.01.25.
//

import SwiftUI

struct DynamicTextEditor: View {
    let placeholder: String
    @Binding var text: String
    @State private var textHeight: CGFloat = 40
    var minHeight: CGFloat = 40 // Allow customization of default height

    var body: some View {
        // this is a text edito that is scrollable and adjusts its height based on the text
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.secondary).opacity(0.5)
                    .padding(.leading, 4)
                    .padding(.top, 10)
            }

            TextEditor(text: $text)
                .frame(height: textHeight)
        }
        .onAppear {
            updateHeight()
        }
        .onChange(of: text) {
            updateHeight()
        }
    }

    // here we calculate the height of the text (a bit smaller) to set the height of the text editor
    private func updateHeight() {
        let textSize = text.heightWithConstrainedWidth(width: UIScreen.main.bounds.width - 40, font: UIFont.systemFont(ofSize: 17))
        textHeight = max(minHeight, textSize + 20)
    }
}

// custom extension to calculate the height of the text
extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
}
