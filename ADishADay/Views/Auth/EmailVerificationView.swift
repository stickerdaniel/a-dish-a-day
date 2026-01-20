//
//  EmailVerificationView.swift
//  A Dish A Day
//

import Inject
import SwiftUI

/// Screen shown after signup prompting user to verify their email.
struct EmailVerificationView: View {
  @ObserveInjection var inject
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var authManager: AuthenticationManager

  let email: String
  let password: String

  @State private var isVerifying = false
  @State private var errorMessage: String?

  var body: some View {
    Form {
      // Instructions section
      Section {
        Text(email)
          .fontWeight(.medium)
      } header: {
        Text("We sent a verification link!")
      } footer: {
        VStack(alignment: .leading, spacing: 4) {
          if let error = errorMessage {
            Text(error)
              .foregroundStyle(.red)
          }
          Text("Didn't receive it? Check your spam folder")
        }
      }

      // Primary action - last on page
      Section {
        Button {
          Task {
            await verifyAndLogin()
          }
        } label: {
          HStack {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
            Text("I've Verified My Email")
            Spacer()
          }
          .opacity(isVerifying ? 0 : 1)
          .overlay {
            if isVerifying {
              ProgressView()
                .controlSize(.regular)
            }
          }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(isVerifying)
      }
      .listRowInsets(EdgeInsets())
    }
    .contentMargins(.top, 40)
    .navigationTitle("Verify Email")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "xmark")
            .foregroundStyle(.secondary)
        }
        .disabled(isVerifying)
      }
    }
    .onChange(of: authManager.authState) { _, newState in
      // Dismiss all the way back when authenticated
      if newState.isAuthenticated {
        dismiss()
      }
    }
    .enableInjection()
  }

  private func verifyAndLogin() async {
    isVerifying = true
    errorMessage = nil

    do {
      // Attempt to log in - if email isn't verified, Auth0 will return an error
      try await authManager.login(email: email, password: password)
      // If successful, onChange will dismiss
    } catch let error as AuthError {
      if case .emailNotVerified = error {
        errorMessage =
          "Email not yet verified. Please check your inbox and click the verification link."
      } else {
        errorMessage = error.localizedDescription
      }
    } catch {
      errorMessage = error.localizedDescription
    }

    isVerifying = false
  }
}

#Preview {
  NavigationStack {
    EmailVerificationView(
      email: "test@example.com",
      password: "Test1234!@"
    )
    .environmentObject(AuthenticationManager.shared)
  }
}
