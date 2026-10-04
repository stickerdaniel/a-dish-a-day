//
//  FileImportHandler.swift
//  calendar
//
//  Created by Daniel Sticker on 24.01.25.
//  helper for importing files (used for default calendars and import)

import SwiftUI
import UniformTypeIdentifiers

struct FileImportHandler<T> {
  let handleImport: (URL) throws -> T
  let onSuccess: (T) -> Void
  let onError: (Error) -> Void

  /// Processes a file import by automatically detecting if it's a bundle resource
  func process(_ result: Result<URL, Error>) {
    switch result {
    case .success(let url):
      let isBundleResource = url.path.hasPrefix(Bundle.main.bundlePath)

      if !isBundleResource {
        guard url.startAccessingSecurityScopedResource() else {
          onError(URLError(.cannotOpenFile))
          return
        }
      }

      defer {
        if !isBundleResource {
          url.stopAccessingSecurityScopedResource()
        }
      }

      let fileCoordinator = NSFileCoordinator()
      var readError: NSError?
      var importResult: Result<T, Error>?

      fileCoordinator.coordinate(readingItemAt: url, options: [], error: &readError) { securedURL in
        importResult = Result { try handleImport(securedURL) }
      }

      if let readError {
        onError(readError)
        return
      }

      switch importResult {
      case .success(let imported):
        onSuccess(imported)
      case .failure(let error):
        onError(error)
      case nil:
        onError(URLError(.cannotDecodeContentData))
      }

    case .failure(let error):
      onError(error)
    }
  }
}
