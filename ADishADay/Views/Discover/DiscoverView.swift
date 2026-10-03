//
//  DiscoverView.swift
//  ADishADay
//

import Auth0
import ConvexMobile
import Inject
import SwiftUI

struct DiscoverView: View {
  @ObserveInjection var inject
  @EnvironmentObject private var authManager: AuthenticationManager

  @State private var loginPresentation: LoginPresentation?
  @State private var isShowingSettings = false
  @State private var tasks: [ConvexTask] = []
  @State private var isLoading = false
  @State private var subscriptionTask: Task<Void, Never>?
  @State private var subscriptionID = UUID()
  @State private var subscriptionError: String?
  @State private var toggleError: String?
  @State private var isRetrying = false

  private var convex: ConvexClientWithAuth<Credentials> {
    ConvexClientManager.client
  }

  var body: some View {
    Group {
      switch authManager.authState {
      case .unknown:
        ProgressView("Starting up...")

      case .loading:
        ProgressView("Connecting...")

      case .unauthenticated:
        unauthenticatedView

      case .offline:
        retryView(
          title: "You're Offline",
          systemImage: "wifi.slash",
          message: "Your account is still signed in.\nConnect to the internet and try again."
        )

      case .authenticated:
        authenticatedContent
      }
    }
    .navigationTitle("Discover")
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          isShowingSettings = true
        } label: {
          Image(systemName: "gearshape")
        }
      }
    }
    .fullScreenCover(isPresented: $isShowingSettings) {
      NavigationStack {
        SettingsView()
          .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
              Button {
                isShowingSettings = false
              } label: {
                Image(systemName: "xmark")
              }
            }
          }
      }
    }
    .fullScreenCover(item: $loginPresentation) { presentation in
      NavigationStack {
        LoginView(initialTab: presentation.tab)
          .environmentObject(authManager)
      }
    }
    .onChange(of: authManager.isConvexReady) { _, isReady in
      handleReadinessChange(isReady)
    }
    .alert(
      "Could Not Update Task",
      isPresented: Binding(
        get: { toggleError != nil },
        set: { if !$0 { toggleError = nil } }
      )
    ) {
      Button("OK", role: .cancel) {}
    } message: {
      if let toggleError {
        Text(toggleError)
      }
    }
    .enableInjection()
  }

  // MARK: - Unauthenticated View

  private var unauthenticatedView: some View {
    ContentUnavailableView {
      Label("Account Required", systemImage: "person.crop.circle.badge.ellipsis")
    } description: {
      Text("Sign in to access cloud features\nand discover new recipes.")
    } actions: {
      HStack(spacing: 16) {
        Button("Sign Up") {
          loginPresentation = LoginPresentation(tab: .signup)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)

        Button("Log In") {
          loginPresentation = LoginPresentation(tab: .login)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
      }
    }
    .offset(y: -40)
  }

  // MARK: - Retry View

  /// Offline or failed Convex login: Retry resumes the failed stage through the auth owner.
  private func retryView(title: String, systemImage: String, message: String) -> some View {
    ContentUnavailableView {
      Label(title, systemImage: systemImage)
    } description: {
      Text(message)
    } actions: {
      Button {
        Task {
          isRetrying = true
          await authManager.connectConvex()
          isRetrying = false
        }
      } label: {
        Text("Retry")
          .opacity(isRetrying ? 0 : 1)
          .overlay {
            if isRetrying {
              ProgressView()
                .controlSize(.regular)
            }
          }
      }
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
      .disabled(isRetrying)
    }
    .offset(y: -40)
  }

  // MARK: - Authenticated Content

  private var authenticatedContent: some View {
    Group {
      if let failure = authManager.convexAuthFailure {
        retryView(title: "Not Connected", systemImage: "exclamationmark.icloud", message: failure)
      } else if !authManager.isConvexReady {
        ProgressView("Connecting...")
      } else if let subscriptionError {
        subscriptionErrorView(message: subscriptionError)
      } else if isLoading {
        ProgressView("Loading tasks...")
      } else if tasks.isEmpty {
        ContentUnavailableView(
          "No Tasks",
          systemImage: "checklist",
          description: Text("Tasks will appear here when added to Convex")
        )
      } else {
        tasksList
      }
    }
    .safeAreaInset(edge: .top) {
      if authManager.isConvexReady && authManager.transport == .connecting {
        offlineBanner
      }
    }
    .onAppear {
      startSubscription()
    }
    .onDisappear {
      stopSubscription()
    }
  }

  private var offlineBanner: some View {
    Label("Offline, waiting for connection", systemImage: "wifi.slash")
      .font(.footnote)
      .foregroundStyle(.secondary)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 8)
      .background(.bar)
  }

  private func subscriptionErrorView(message: String) -> some View {
    ContentUnavailableView {
      Label("Could Not Load Tasks", systemImage: "exclamationmark.triangle")
    } description: {
      Text(message)
    } actions: {
      Button("Retry") {
        restartSubscription()
      }
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
    }
    .offset(y: -40)
  }

  private var tasksList: some View {
    List(tasks) { task in
      HStack {
        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
          .foregroundStyle(task.isCompleted ? .green : .secondary)
        Text(task.text)
          .strikethrough(task.isCompleted)
          .foregroundStyle(task.isCompleted ? .secondary : .primary)
      }
      .contentShape(Rectangle())
      .onTapGesture {
        toggleTask(id: task._id)
      }
    }
  }

  // MARK: - Subscription Management

  private func handleReadinessChange(_ isReady: Bool) {
    if isReady {
      startSubscription()
    } else {
      stopSubscription()
      tasks = []
      subscriptionError = nil
    }
  }

  /// Subscribes once the auth owner installed Convex auth, whatever the WebSocket state.
  private func startSubscription() {
    guard subscriptionTask == nil, subscriptionError == nil, authManager.isConvexReady else {
      return
    }

    let id = UUID()
    subscriptionID = id
    subscriptionTask = Task {
      await subscribeToTasks()
      // A replaced subscription must not clear its successor's handle
      if subscriptionID == id {
        subscriptionTask = nil
      }
    }
  }

  private func stopSubscription() {
    subscriptionTask?.cancel()
    subscriptionTask = nil
  }

  private func restartSubscription() {
    stopSubscription()
    subscriptionError = nil
    startSubscription()
  }

  private func toggleTask(id: String) {
    Task {
      do {
        try await convex.mutation("tasks:toggle", with: ["id": id])
      } catch {
        print("[Convex] Toggle failed: \(type(of: error))")
        toggleError = "The task could not be updated. Please try again."
      }
    }
  }

  private func subscribeToTasks() async {
    isLoading = true

    do {
      for try await result: [ConvexTask] in convex.subscribe(to: "tasks:get").values {
        guard !Task.isCancelled else { return }
        isLoading = false
        tasks = result
        authManager.noteQueryResult()
      }
    } catch {
      print("[Convex] Subscription failed: \(type(of: error))")
    }

    // The stream only ends on an error; show it instead of an empty list
    guard !Task.isCancelled else { return }
    isLoading = false
    subscriptionError = "Tasks could not be loaded."
  }
}

#Preview {
  NavigationStack {
    DiscoverView()
      .environmentObject(AuthenticationManager.shared)
  }
}
