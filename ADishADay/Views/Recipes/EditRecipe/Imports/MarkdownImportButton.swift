//
//  MarkdownImportButton.swift
//  calendar
//
//  Created by Daniel Sticker on 24.01.25.
//  Another cool feature that allows users import recipes from markdown files
// # Title
// ## Ingredients
// ## Instructions

import SwiftUI

struct MarkdownImportButton: View {
  @State private var isImportingMarkdown = false
  @State private var showImportError = false
  @State private var importErrorMessage = ""
  let onMarkdownImported: (String, String, String) -> Void

  var body: some View {
    Button(
      action: { isImportingMarkdown = true },
      label: {
        HStack {
          Image(systemName: "text.line.first.and.arrowtriangle.forward")
            .frame(width: 24, height: 24)
          Text("Markdown")
            .foregroundColor(.primary)
        }
      }
    )
    .fileImporter(
      isPresented: $isImportingMarkdown,
      allowedContentTypes: [.plainText],
      onCompletion: handleMarkdownImport
    )
    .alert(
      "Import Warning",
      isPresented: $showImportError,
      actions: {
        Button("Ok", role: .cancel) {}
      },
      message: {
        Text(importErrorMessage)
      }
    )
  }

  private func handleMarkdownImport(_ result: Result<URL, Error>) {
    switch result {
    case .success(let url):
      guard url.startAccessingSecurityScopedResource() else { return }
      defer { url.stopAccessingSecurityScopedResource() }

      do {
        let markdown = try String(contentsOf: url)
        let parsed = RecipeMarkdownParser.parse(markdown: markdown)

        if let errorMessage = parsed.errorMessage {
          importErrorMessage = errorMessage
          showImportError = true
        }

        onMarkdownImported(parsed.name, parsed.ingredients, parsed.instructions)
      } catch {
        importErrorMessage = "Failed to read markdown file"
        showImportError = true
      }
    case .failure:
      importErrorMessage = "Failed to access selected file"
      showImportError = true
    }
  }
}
