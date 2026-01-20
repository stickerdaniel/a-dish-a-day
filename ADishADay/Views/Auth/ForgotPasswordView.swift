//
//  ForgotPasswordView.swift
//  A Dish A Day
//

import Inject
import SwiftUI

/// Sheet shown when user taps "Forgot Password" to request a password reset email.
struct ForgotPasswordView: View {
  @ObserveInjection var inject
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var authManager: AuthenticationManager

  @State var email: String = ""

  @State private var isSending = false
  @State private var emailSent = false
  @State private var errorMessage: String?

  var body: some View {
    NavigationStack {
      Form {
        Section {
          TextField("Email", text: $email)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .disabled(isSending || emailSent)
        } header: {
          Text("Reset your password")
        } footer: {
          VStack(alignment: .leading, spacing: 4) {
            if let error = errorMessage {
              Text(error)
                .foregroundStyle(.red)
            } else if emailSent {
              Text("Check your inbox for instructions to reset your password.")
                .foregroundStyle(.green)
            } else {
              Text("Enter your email and we'll send you a link to reset your password.")
            }
          }
        }

        // Primary action
        Section {
          Button {
            Task {
              await sendResetEmail()
            }
          } label: {
            HStack {
              Spacer()
              if emailSent {
                Image(systemName: "checkmark.circle.fill")
                Text("Email Sent")
              } else {
                Image(systemName: "envelope.badge.shield.half.filled")
                  .symbolRenderingMode(.monochrome)
                Text("Send Reset Email")
              }
              Spacer()
            }
            .opacity(isSending ? 0 : 1)
            .overlay {
              if isSending {
                ProgressView()
                  .controlSize(.regular)
              }
            }
          }
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .disabled(isSending || emailSent || !isValidEmail)
        }
        .listRowInsets(EdgeInsets())
      }
      .contentMargins(.top, 40)
      .navigationTitle("Forgot Password")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark")
              .foregroundStyle(.secondary)
          }
          .disabled(isSending)
        }
      }
      .enableInjection()
    }
  }

  private var isValidEmail: Bool {
    let emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
    return email.wholeMatch(of: emailRegex) != nil
  }

  private func sendResetEmail() async {
    isSending = true
    errorMessage = nil

    do {
      try await authManager.resetPassword(email: email)
      emailSent = true
    } catch let error as AuthError {
      errorMessage = error.localizedDescription
    } catch {
      errorMessage = error.localizedDescription
    }

    isSending = false
  }
}

#Preview {
  ForgotPasswordView(email: "test@example.com")
    .environmentObject(AuthenticationManager.shared)
}
