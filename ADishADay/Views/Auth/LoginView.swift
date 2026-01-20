//
//  LoginView.swift
//  A Dish A Day
//

import Inject
import SwiftUI

// MARK: - Supporting Types

enum AuthTab: String, CaseIterable {
  case signup = "Sign Up"
  case login = "Log In"
}

/// Wrapper to trigger fresh LoginView presentation with correct tab
struct LoginPresentation: Identifiable {
  let id = UUID()
  let tab: AuthTab
}

// MARK: - Login View

struct LoginView: View {
  @ObserveInjection var inject
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var authManager: AuthenticationManager

  let initialTab: AuthTab

  @State private var selectedTab: AuthTab = .signup

  init(initialTab: AuthTab = .signup) {
    self.initialTab = initialTab
  }
  @State private var showVerification = false
  @State private var showForgotPassword = false
  @State private var email = ""
  @State private var password = ""
  @State private var confirmPassword = ""
  @State private var isSubmitting = false
  @State private var errorMessage: String?

  // MARK: - Validation

  private var isValidEmail: Bool {
    let emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
    return email.wholeMatch(of: emailRegex) != nil
  }

  private var hasMinLength: Bool {
    password.count >= 8
  }

  private var characterTypesCount: Int {
    [hasUppercase, hasLowercase, hasNumber, hasSpecialCharacter].filter { $0 }.count
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
    hasMinLength && characterTypesCount >= 3
  }

  private var passwordsMatch: Bool {
    password == confirmPassword
  }

  private var canSubmit: Bool {
    if selectedTab == .login {
      return isValidEmail && !password.isEmpty && !isSubmitting
    } else {
      return isValidEmail && isValidPassword && passwordsMatch && !isSubmitting
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
          password: password
        )
        .environmentObject(authManager)
      }
      .onChange(of: authManager.authState) { _, newState in
        // Dismiss when authenticated
        if newState.isAuthenticated {
          dismiss()
        }
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
          .disabled(isSubmitting)

        SecureField("Password", text: $password)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled()
          .textContentType(selectedTab == .login ? .password : .newPassword)
          .disabled(isSubmitting)

        if selectedTab == .signup {
          SecureField("Confirm Password", text: $confirmPassword)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textContentType(.newPassword)
            .disabled(isSubmitting)
        }
      } header: {
        Text(selectedTab == .login ? "Welcome back" : "Create an account")
      } footer: {
        VStack(alignment: .leading, spacing: 4) {
          if let error = errorMessage {
            Text(error)
              .foregroundStyle(.red)
          } else if let error = validationError {
            Text(error)
              .foregroundStyle(.red)
          }
          if selectedTab == .signup && !password.isEmpty {
            if isValidPassword && (confirmPassword.isEmpty || passwordsMatch) {
              PasswordRequirementRow(text: "Valid password", isMet: true)
            } else if !isValidPassword {
              PasswordRequirementRow(text: "At least 8 characters", isMet: hasMinLength)
              Text("At least 3 of the following:")
                .font(.caption)
                .foregroundStyle(.secondary)
              PasswordRequirementRow(
                text: "Lower case letters (a-z)", isMet: hasLowercase, indented: true)
              PasswordRequirementRow(
                text: "Upper case letters (A-Z)", isMet: hasUppercase, indented: true)
              PasswordRequirementRow(text: "Numbers (0-9)", isMet: hasNumber, indented: true)
              PasswordRequirementRow(
                text: "Special characters (!@#$%^&*)", isMet: hasSpecialCharacter, indented: true)
            }
          }
          if selectedTab == .login {
            Button("Forgot Password?") {
              showForgotPassword = true
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
          Task {
            await performAuth()
          }
        } label: {
          HStack {
            Spacer()
            Image(systemName: selectedTab == .login ? "arrow.right" : "person.badge.plus")
            Text(selectedTab == .login ? "Log In" : "Create Account")
            Spacer()
          }
          .opacity(isSubmitting ? 0 : 1)
          .overlay {
            if isSubmitting {
              ProgressView()
                .controlSize(.regular)
            }
          }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(!canSubmit)
      }
      .listRowInsets(EdgeInsets())

    }
    .navigationTitle("Welcome")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "xmark")
            .foregroundStyle(.secondary)
        }
        .disabled(isSubmitting)
      }
    }
    .onChange(of: selectedTab) {
      // Clear confirm password and error when switching tabs
      confirmPassword = ""
      errorMessage = nil
    }
    .sheet(isPresented: $showForgotPassword) {
      ForgotPasswordView(email: email)
        .environmentObject(authManager)
    }
    .onAppear {
      selectedTab = initialTab
    }
    .enableInjection()
  }

  // MARK: - Actions

  private func performAuth() async {
    errorMessage = nil
    isSubmitting = true
    defer { isSubmitting = false }

    do {
      if selectedTab == .login {
        try await authManager.login(email: email, password: password)
        // Dismiss handled by onChange of authState
      } else {
        try await authManager.signup(email: email, password: password)
        // Show verification screen after successful signup
        showVerification = true
      }
    } catch let error as AuthError {
      errorMessage = error.localizedDescription
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}

// MARK: - Previews

#Preview("Login") {
  NavigationStack {
    LoginView()
      .environmentObject(AuthenticationManager.shared)
  }
}

#Preview("Sign Up") {
  NavigationStack {
    LoginView(initialTab: .signup)
      .environmentObject(AuthenticationManager.shared)
  }
}
