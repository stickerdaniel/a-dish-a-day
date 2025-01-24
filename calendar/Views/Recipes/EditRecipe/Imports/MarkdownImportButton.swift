//
//  MarkdownImportButton.swift
//  calendar
//
//  Created by Daniel Sticker on 24.01.25.
//

import SwiftUI

struct MarkdownImportButton: View {
    @State private var isImportingMarkdown = false
    @State private var showImportError = false
    let onMarkdownImported: (String, String, String) -> Void
    
    var body: some View {
        Button(action: { isImportingMarkdown = true }) {
            VStack(spacing: 8) {
                Image(systemName: "tray.and.arrow.down")
                    .font(.system(size: 24))
                Text("Markdown")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .fileImporter(
            isPresented: $isImportingMarkdown,
            allowedContentTypes: [.plainText],
            onCompletion: handleMarkdownImport
        )
        .alert("Import Error", isPresented: $showImportError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Failed to import markdown file.")
        }
    }
    
    private func handleMarkdownImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let markdown = try String(contentsOf: url)
                let parsed = try RecipeMarkdownParser.parse(markdown: markdown)
                onMarkdownImported(parsed.name, parsed.ingredients, parsed.instructions)
            } catch {
                showImportError = true
            }
        case .failure:
            showImportError = true
        }
    }
}
