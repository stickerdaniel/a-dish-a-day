//
//  LoginView.swift
//  A Dish A Day
//

import Inject
import SwiftUI

// MARK: - Supporting Types

enum AuthTab: String, CaseIterable {
  case signup = "Sign Up"
  case login = "Login"
}

// MARK: - Login View

struct LoginView: View {
  @ObserveInjection var inject
  @Environment(\.dismiss) private var dismiss

  @Binding var isLoggedIn: Bool
  @State private var selectedTab: AuthTab = .signup
  @State private var showVerification = false
  @State private var email = ""
  @State private var password = ""
  @State private var confirmPassword = ""

  // MARK: - Validation

  private var isValidEmail: Bool {
    let emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
    return email.wholeMatch(of: emailRegex) != nil
  }

  private var hasMinLength: Bool {
    password.count >= 10
  }

  private var hasUppercase: Bool {
    password.contains(where: \.isUppercase)
  }

  private var hasLowercase: Bool {
    password.contains(where: \.isLowercase)
  }

  private var hasNumber: Bool {
    password.contains(where: \.isNumber)
  }

  private var hasSpecialCharacter: Bool {
    let specialCharacters = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;':\",./<>?")
    return password.unicodeScalars.contains { specialCharacters.contains($0) }
  }

  private var isValidPassword: Bool {
    hasMinLength && hasUppercase && hasLowercase && hasNumber && hasSpecialCharacter
  }

  private var passwordsMatch: Bool {
    password == confirmPassword
  }

  private var canSubmit: Bool {
    if selectedTab == .login {
      return isValidEmail && !password.isEmpty
    } else {
      return isValidEmail && isValidPassword && passwordsMatch
    }
  }

  private var validationError: String? {
    if !email.isEmpty && !isValidEmail {
      return "Please enter a valid email address"
    }
    if selectedTab == .signup && !confirmPassword.isEmpty && !passwordsMatch {
      return "Passwords do not match"
    }
    return nil
  }

  // MARK: - Body

  var body: some View {
    credentialsView
      .navigationDestination(isPresented: $showVerification) {
        EmailVerificationView(
          email: email,
          onVerified: {
            isLoggedIn = true
          }
        )
      }
  }

  // MARK: - Credentials View

  private var credentialsView: some View {
    Form {
      // Tab picker
      Section {
        Picker("", selection: $selectedTab) {
          ForEach(AuthTab.allCases, id: \.self) { tab in
            Text(tab.rawValue).tag(tab)
          }
        }
        .pickerStyle(.segmented)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
      }

      // Credentials section
      Section {
        TextField("Email", text: $email)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled()
          .keyboardType(.emailAddress)
          .textContentType(.emailAddress)

        SecureField("Password", text: $password)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled()
          .textContentType(selectedTab == .login ? .password : .newPassword)

        if selectedTab == .signup {
          SecureField("Confirm Password", text: $confirmPassword)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textContentType(.newPassword)
        }
      } header: {
        Text(selectedTab == .login ? "Welcome back" : "Create an account")
      } footer: {
        VStack(alignment: .leading, spacing: 4) {
          if let error = validationError {
            Text(error)
              .foregroundStyle(.red)
          }
          if selectedTab == .signup && !password.isEmpty {
            if isValidPassword && (confirmPassword.isEmpty || passwordsMatch) {
              PasswordRequirementRow(text: "Valid password", isMet: true)
            } else if !isValidPassword {
              PasswordRequirementRow(text: "At least 10 characters", isMet: hasMinLength)
              PasswordRequirementRow(text: "One uppercase letter", isMet: hasUppercase)
              PasswordRequirementRow(text: "One lowercase letter", isMet: hasLowercase)
              PasswordRequirementRow(text: "One number", isMet: hasNumber)
              PasswordRequirementRow(text: "One special character", isMet: hasSpecialCharacter)
            }
          }
          if selectedTab == .login {
            Button("Forgot Password?") {
              print("Forgot password tapped")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .trailing)
          }
        }
      }

      // Primary action
      Section {
        Button {
          performAuth()
        } label: {
          HStack {
            Spacer()
            Text(selectedTab == .login ? "Sign In" : "Create Account")
            Image(systemName: selectedTab == .login ? "arrow.right" : "person.badge.plus")
            Spacer()
          }
        }
        .disabled(!canSubmit)
      }

    }
    .navigationTitle("Welcome")
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
    .onChange(of: selectedTab) {
      // Clear confirm password when switching tabs
      confirmPassword = ""
    }
    .enableInjection()
  }

  // MARK: - Actions

  private func performAuth() {
    if selectedTab == .login {
      // Login - go directly to app (placeholder)
      isLoggedIn = true
    } else {
      // Sign up - show verification screen
      showVerification = true
    }
  }

}

// MARK: - Previews

#Preview("Login") {
  @Previewable @State var isLoggedIn = false
  NavigationStack {
    LoginView(isLoggedIn: $isLoggedIn)
  }
}

#Preview("Sign Up") {
  @Previewable @State var isLoggedIn = false
  NavigationStack {
    LoginView(isLoggedIn: $isLoggedIn)
  }
}
