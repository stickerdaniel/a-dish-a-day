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
            print("Importing file from \(url)")
            print("Detected bundle resource: \(isBundleResource)")

            if !isBundleResource {
                print("Starting file access")
                guard url.startAccessingSecurityScopedResource() else {
                    print("Failed to access security scoped resource.")
                    onError(URLError(.cannotOpenFile))
                    return
                }
            } else {
                print("Skipping security-scoped access for bundle resource.")
            }

            defer {
                if !isBundleResource {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            do {
                let fileCoordinator = NSFileCoordinator()
                var error: NSError?
                var imported: T?

                fileCoordinator.coordinate(readingItemAt: url, options: [], error: &error) { securedURL in
                    do {
                        imported = try handleImport(securedURL)
                    } catch {
                        print("Error decoding calendar: \(error.localizedDescription)")
                        onError(error)
                    }
                }

                if let error = error {
                    print("File coordination error: \(error.localizedDescription)")
                    onError(error)
                    return
                }

                if let imported = imported {
                    onSuccess(imported)
                } else {
                    onError(URLError(.cannotDecodeContentData))
                }
                
            } catch {
                print("Unhandled error during file import: \(error.localizedDescription)")
                onError(error)
            }

        case .failure(let error):
            onError(error)
        }
    }
}
