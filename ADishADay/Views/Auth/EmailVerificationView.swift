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

  let email: String
  let onVerified: () -> Void

  @State private var isResending = false
  @State private var showResendConfirmation = false

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
          Text("Didn't receive it? Check your spam folder")
          Button {
            resendEmail()
          } label: {
            if isResending {
              Text("Sending...")
            } else {
              Text("Resend Email")
            }
          }
          .font(.footnote)
          .foregroundStyle(.secondary)
          .disabled(isResending)
          .frame(maxWidth: .infinity, alignment: .trailing)
        }
      }

      // Primary action - last on page
      Section {
        Button {
          onVerified()
        } label: {
          HStack {
            Spacer()
            Text("I've Verified My Email")
            Image(systemName: "checkmark.seal.fill")
            Spacer()
          }
        }
      }
    }
    .contentMargins(.top, 40)
    .navigationTitle("Verify Email")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "xmark.circle.fill")
            .foregroundStyle(.secondary)
        }
      }
    }
    .alert("Email Sent", isPresented: $showResendConfirmation) {
      Button("OK", role: .cancel) {}
    } message: {
      Text("A new verification email has been sent to \(email)")
    }
    .enableInjection()
  }

  private func resendEmail() {
    isResending = true
    // Simulate sending email
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      isResending = false
      showResendConfirmation = true
    }
  }
}

#Preview {
  NavigationStack {
    EmailVerificationView(
      email: "test@example.com",
      onVerified: { print("Verified") }
    )
  }
}
