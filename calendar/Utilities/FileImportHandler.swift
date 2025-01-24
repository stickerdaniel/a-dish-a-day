//
//  FileImportHandler.swift
//  calendar
//
//  Created by Daniel Sticker on 24.01.25.
//

import SwiftUI
import UniformTypeIdentifiers

struct FileImportHandler<T> {
    let handleImport: (URL) throws -> T
    let onSuccess: (T) -> Void
    let onError: (Error) -> Void
    
    func process(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            guard url.startAccessingSecurityScopedResource() else {
                onError(URLError(.cannotOpenFile))
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let imported = try handleImport(url)
                onSuccess(imported)
            } catch {
                onError(error)
            }
        case .failure(let error):
            onError(error)
        }
    }
}