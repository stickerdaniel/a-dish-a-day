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
    .onChange(of: authManager.authState) { _, newState in
      handleAuthStateChange(newState)
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

  // MARK: - Authenticated Content

  private var authenticatedContent: some View {
    Group {
      if isLoading {
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
    .onAppear {
      startSubscription()
    }
    .onDisappear {
      stopSubscription()
    }
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

  private func handleAuthStateChange(_ state: AuthState) {
    if state.isAuthenticated {
      startSubscription()
    } else {
      stopSubscription()
      tasks = []
    }
  }

  private func startSubscription() {
    guard subscriptionTask == nil, authManager.authState.isAuthenticated else { return }

    subscriptionTask = Task {
      // Authenticate with Convex using cached credentials
      _ = await convex.login()
      print("[Convex] Authenticated successfully")
      await subscribeToTasks()
    }
  }

  private func stopSubscription() {
    subscriptionTask?.cancel()
    subscriptionTask = nil
  }

  private func toggleTask(id: String) {
    Task {
      try? await convex.mutation("tasks:toggle", with: ["id": id])
    }
  }

  private func subscribeToTasks() async {
    isLoading = true

    for await result: [ConvexTask] in convex.subscribe(to: "tasks:get")
      .replaceError(with: [])
      .values
    {
      guard !Task.isCancelled else { break }
      isLoading = false
      tasks = result
    }
  }
}

#Preview {
  NavigationStack {
    DiscoverView()
      .environmentObject(AuthenticationManager.shared)
  }
}
