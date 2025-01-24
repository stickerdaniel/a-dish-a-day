//
//  AIScanButton.swift
//  calendar
//
//  Created by Daniel Sticker on 24.01.25.
//

import SwiftUI
import PhotosUI

struct AIScanButton: View {
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showSourceActionSheet = false
    @State private var selectedImage: UIImage?
    @State private var showSettingsAlert = false
    @State private var showSettingsSheet = false 
    @State private var showProcessingProgress = false
    @State private var processingStep = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var retryCount = 0
    private let maxRetries = 3
    
    let onImageScanned: (String, String, String) -> Void
    
    var body: some View {
        Button(action: validateAndProceed) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                    .frame(width: 24)
                VStack(alignment: .leading) {
                    Text("AI Scan")
                        .font(.body)
                        .foregroundColor(.primary)
                    if showProcessingProgress {
                        HStack {
                            ProgressView()
                                .tint(.blue)
                            Text(processingStep)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
        .alert("OpenAI API Key Required", isPresented: $showSettingsAlert) {
            Button("Open Settings") {
                showSettingsSheet = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please set your OpenAI API key in the settings to use the AI Scan feature.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showSettingsSheet) {
            SettingsView()
        }
        .actionSheet(isPresented: $showSourceActionSheet) {
            ActionSheet(
                title: Text("Select Image Source"),
                buttons: [
                    .default(Text("Camera")) {
                        let status = AVCaptureDevice.authorizationStatus(for: .video)
                        switch status {
                        case .authorized:
                            showCamera = true
                        case .notDetermined:
                            AVCaptureDevice.requestAccess(for: .video) { granted in
                                if granted {
                                    DispatchQueue.main.async {
                                        showCamera = true
                                    }
                                }
                            }
                        case .denied, .restricted:
                            errorMessage = "Camera access is required. Please enable it in Settings."
                            showError = true
                        @unknown default:
                            break
                        }
                    },
                    .default(Text("Photo Library")) {
                        showImagePicker = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
                .onDisappear {
                    if let image = selectedImage {
                        Task {
                            await processImage(image)
                        }
                    }
                }
        }
        .photosPicker(
            isPresented: $showImagePicker,
            selection: .init(get: { nil }, set: { item in
                guard let item = item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        await processImage(image)
                    }
                }
            }),
            matching: .images
        )
    }
    
    private func validateAndProceed() {
        guard let apiKey = UserDefaults.standard.string(forKey: "openai_api_key") else {
            showSettingsAlert = true
            return
        }
        
        if apiKey.count < 20 {
            errorMessage = "The OpenAI API key appears to be invalid. Please check your settings."
            showError = true
            return
        }
        
        showSourceActionSheet = true
    }
    
    private func processImage(_ image: UIImage) async {        
        await MainActor.run {
            print("Starting to process image")
            processingStep = "Analyzing recipe..."
            showProcessingProgress = true
        }
        
        do {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                let openAI = OpenAIIntegration()
                openAI.analyzeRecipeImage(imageData: imageData) { result in
                    Task { @MainActor in
                        showProcessingProgress = false
                        switch result {
                        case .success(let recipe):
                            // debug print
                            print("Title: \(recipe.title)")
                            onImageScanned(recipe.title, recipe.ingredients, recipe.instructions)
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                    }
                }
            }
        } catch OpenAIError.missingAPIKey {
            await showErrorMessage("OpenAI API key is missing. Please add it in settings.")
            showSettingsAlert = true
        } catch OpenAIError.requestFailed(let statusCode) {
            switch statusCode {
            case 401:
                await showErrorMessage("Invalid API key. Please check your settings.")
                showSettingsAlert = true
            case 429:
                await showErrorMessage("Too many requests. Please try again later.")
            case 500, 502, 503, 504:
                if retryCount < maxRetries {
                    retryCount += 1
                    try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * Double(retryCount)))
                    await processImage(image)
                } else {
                    await showErrorMessage("Server error. Please try again later.")
                }
            default:
                await showErrorMessage("Failed to process the image (Error \(statusCode)). Please try again.")
            }
        } catch OpenAIError.invalidData {
            await showErrorMessage("Failed to parse the recipe data. Please try a different image.")
        } catch {
            await showErrorMessage("An unexpected error occurred. Please try again.")
            print("Error processing image: \(error)")
        }
    }
    
    private func showErrorMessage(_ message: String) async {
        await MainActor.run {
            showProcessingProgress = false
            errorMessage = message
            showError = true
        }
    }
}

// Image Picker for Camera
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                 didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
