//
//  LoginView.swift
//  A Dish A Day
//

// swiftlint:disable file_types_order

import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

// MARK: - Supporting Types

enum AuthTab: String, CaseIterable {
  case login = "Login"
  case signup = "Sign Up"
}

enum AuthState {
  case login
  case verifyEmail(email: String)
  case authenticated
}

// MARK: - Login View

struct LoginView: View {
  @ObserveInjection var inject

  @Binding var isLoggedIn: Bool
  @State private var selectedTab: AuthTab = .login
  @State private var authState: AuthState = .login
  @State private var email = ""
  @State private var password = ""
  @State private var confirmPassword = ""

  // MARK: - Validation

  private var isValidEmail: Bool {
    let emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
    return email.wholeMatch(of: emailRegex) != nil
  }

  private var hasMinLength: Bool {
    password.count >= 8
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

  var body: some View {
    switch authState {
    case .login:
      loginContent
    case .verifyEmail(let emailAddress):
      EmailVerificationView(
        email: emailAddress,
        onVerified: {
          isLoggedIn = true
        },
        onBack: {
          authState = .login
        }
      )
    case .authenticated:
      Color.clear.onAppear {
        isLoggedIn = true
      }
    }
  }

  private var loginContent: some View {
    VStack(spacing: 24) {
      // App title
      Text("A Dish A Day")
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding(.top, 60)

      // Tab picker
      Picker("", selection: $selectedTab) {
        ForEach(AuthTab.allCases, id: \.self) { tab in
          Text(tab.rawValue).tag(tab)
        }
      }
      .pickerStyle(.segmented)
      .padding(.horizontal, 32)
      .padding(.top, 20)

      Spacer()

      // Form content
      VStack(spacing: 20) {
        // Email field
        VStack(alignment: .leading, spacing: 8) {
          Text("Email")
            .font(.subheadline)
            .foregroundStyle(.secondary)
          TextField("Enter your email", text: $email)
            .textFieldStyle(.roundedBorder)
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
          if !email.isEmpty && !isValidEmail {
            Text("Please enter a valid email address")
              .font(.caption)
              .foregroundStyle(.red)
          }
        }

        // Password field
        VStack(alignment: .leading, spacing: 8) {
          Text("Password")
            .font(.subheadline)
            .foregroundStyle(.secondary)
          SecureField("Enter your password", text: $password)
            .textFieldStyle(.roundedBorder)
            .textContentType(selectedTab == .login ? .password : .newPassword)

          // Password requirements (only for Sign Up)
          if selectedTab == .signup && !password.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
              PasswordRequirementRow(text: "At least 8 characters", isMet: hasMinLength)
              PasswordRequirementRow(text: "One uppercase letter", isMet: hasUppercase)
              PasswordRequirementRow(text: "One lowercase letter", isMet: hasLowercase)
              PasswordRequirementRow(text: "One number", isMet: hasNumber)
              PasswordRequirementRow(text: "One special character", isMet: hasSpecialCharacter)
            }
            .padding(.top, 4)
          }
        }

        // Confirm Password field (only for Sign Up)
        if selectedTab == .signup {
          VStack(alignment: .leading, spacing: 8) {
            Text("Confirm Password")
              .font(.subheadline)
              .foregroundStyle(.secondary)
            SecureField("Confirm your password", text: $confirmPassword)
              .textFieldStyle(.roundedBorder)
              .textContentType(.newPassword)
            if !confirmPassword.isEmpty && !passwordsMatch {
              Text("Passwords do not match")
                .font(.caption)
                .foregroundStyle(.red)
            }
          }
        }

        // Forgot Password (only for Login)
        if selectedTab == .login {
          HStack {
            Spacer()
            Button("Forgot Password?") {
              // Not functional yet
            }
            .font(.subheadline)
          }
        }
      }
      .padding(.horizontal, 32)

      Spacer()

      // Action button
      Button {
        if selectedTab == .login {
          // Login - go directly to app
          isLoggedIn = true
        } else {
          // Sign up - show verification screen
          authState = .verifyEmail(email: email)
        }
      } label: {
        Text(selectedTab == .login ? "Login" : "Sign Up")
          .frame(maxWidth: .infinity)
          .padding()
          .background(canSubmit ? Color.accentColor : Color.gray)
          .foregroundStyle(.white)
          .cornerRadius(10)
      }
      .disabled(!canSubmit)
      .padding(.horizontal, 32)

      // Divider with "or"
      HStack {
        Rectangle()
          .fill(Color.secondary.opacity(0.3))
          .frame(height: 1)
        Text("or")
          .font(.subheadline)
          .foregroundStyle(.secondary)
        Rectangle()
          .fill(Color.secondary.opacity(0.3))
          .frame(height: 1)
      }
      .padding(.horizontal, 32)
      .padding(.vertical, 8)

      // Social sign-in buttons
      VStack(spacing: 12) {
        // Sign in with Apple
        SignInWithAppleButton(
          selectedTab == .login ? .signIn : .signUp,
          onRequest: { request in
            request.requestedScopes = [.fullName, .email]
          },
          onCompletion: { result in
            handleAppleSignIn(result)
          }
        )
        .signInWithAppleButtonStyle(.black)
        .frame(height: 50)

        // Sign in with Google
        GoogleSignInButton(action: signInWithGoogle)
          .frame(height: 50)
      }
      .padding(.horizontal, 32)
      .padding(.bottom, 40)
    }
    .enableInjection()
  }

  // MARK: - Apple Sign In

  private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
    switch result {
    case .success(let authorization):
      if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
        // Get user data
        let userIdentifier = appleIDCredential.user
        let fullName = appleIDCredential.fullName
        let userEmail = appleIDCredential.email

        // Note: email and fullName are only provided on first sign-in
        // You should store the userIdentifier to identify the user
        print("Apple Sign In successful")
        print("User ID: \(userIdentifier)")
        if let email = userEmail {
          print("Email: \(email)")
        }
        if let name = fullName {
          print("Name: \(name.givenName ?? "") \(name.familyName ?? "")")
        }

        // Backend integration: Send credentials to server for verification
        // The identityToken can be verified server-side with Apple's servers

        isLoggedIn = true
      }
    case .failure(let error):
      print("Apple Sign In failed: \(error.localizedDescription)")

      #if targetEnvironment(simulator)
        // Apple Sign In doesn't work in simulator - bypass for testing
        print("Note: Apple Sign In requires a real device. Bypassing for simulator testing.")
        isLoggedIn = true
      #endif
    }
  }

  // MARK: - Google Sign In

  private func signInWithGoogle() {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let rootViewController = windowScene.windows.first?.rootViewController
    else {
      print("Google Sign In: Could not get root view controller")
      return
    }

    GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
      if let error = error {
        print("Google Sign In failed: \(error.localizedDescription)")
        return
      }

      guard let user = result?.user else {
        print("Google Sign In: No user returned")
        return
      }

      // Get user data
      let userId = user.userID
      let email = user.profile?.email
      let fullName = user.profile?.name

      print("Google Sign In successful")
      print("User ID: \(userId ?? "none")")
      print("Email: \(email ?? "none")")
      print("Name: \(fullName ?? "none")")

      // Backend integration: Send credentials to server for verification
      isLoggedIn = true
    }
  }
}

// MARK: - Password Requirement Row

struct PasswordRequirementRow: View {
  let text: String
  let isMet: Bool

  var body: some View {
    HStack(spacing: 6) {
      Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
        .foregroundStyle(isMet ? .green : .secondary)
        .font(.caption)
      Text(text)
        .font(.caption)
        .foregroundStyle(isMet ? .primary : .secondary)
    }
  }
}

// MARK: - Email Verification View

struct EmailVerificationView: View {
  @ObserveInjection var inject

  let email: String
  let onVerified: () -> Void
  let onBack: () -> Void

  @State private var isResending = false
  @State private var showResendConfirmation = false

  var body: some View {
    VStack(spacing: 24) {
      Spacer()

      // Email icon
      Image(systemName: "envelope.badge")
        .font(.system(size: 80))
        .foregroundStyle(Color.accentColor)

      // Title
      Text("Verify Your Email")
        .font(.largeTitle)
        .fontWeight(.bold)

      // Description
      VStack(spacing: 8) {
        Text("We have sent a verification email to:")
          .foregroundStyle(.secondary)
        Text(email)
          .fontWeight(.semibold)
      }
      .multilineTextAlignment(.center)

      Text("Please check your inbox and click the verification link to continue.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)

      Spacer()

      // Resend email button
      Button {
        resendEmail()
      } label: {
        HStack {
          if isResending {
            ProgressView()
              .tint(.accentColor)
          }
          Text(isResending ? "Sending..." : "Resend Email")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.accentColor.opacity(0.1))
        .foregroundStyle(Color.accentColor)
        .cornerRadius(10)
      }
      .disabled(isResending)
      .padding(.horizontal, 32)

      // Continue button (for demo purposes)
      Button {
        onVerified()
      } label: {
        Text("I've Verified My Email")
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.accentColor)
          .foregroundStyle(.white)
          .cornerRadius(10)
      }
      .padding(.horizontal, 32)

      // Back button
      Button {
        onBack()
      } label: {
        Text("Back to Sign Up")
          .font(.subheadline)
      }
      .padding(.bottom, 40)
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

#Preview("Login") {
  @Previewable @State var isLoggedIn = false
  LoginView(isLoggedIn: $isLoggedIn)
}

#Preview("Verification") {
  EmailVerificationView(
    email: "test@example.com",
    onVerified: {},
    onBack: {}
  )
}

// swiftlint:enable file_types_order
