//
//  PhotoPicker.swift
//  calendar
//
//  Created by Daniel Sticker on 15.01.25.
//

import SwiftUI
import PhotosUI

struct PhotoPicker: View {
    let title: String // Button title
    @Binding var selectedImage: UIImage? // Binding for the selected image

    @State private var pickerItem: PhotosPickerItem? // Store the selected PhotosPickerItem

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
            } else {
                Text("No image selected")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
            }

            PhotosPicker(
                title,
                selection: $pickerItem,
                matching: .images
            )
            .onChange(of: pickerItem) {
                Task {
                    if let data = try? await pickerItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                    } else {
                        print("Failed to load image.")
                    }
                }
            }
        }
    }
}
