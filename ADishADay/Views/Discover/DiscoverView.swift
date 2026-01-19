//
//  DiscoverView.swift
//  ADishADay
//

import ConvexMobile
import Inject
import SwiftUI

struct DiscoverView: View {
  @ObserveInjection var inject
  @State private var isShowingSettings = false
  @State private var tasks: [ConvexTask] = []
  @State private var isLoading = true

  private var convex: ConvexClient {
    ConvexClientManager.client
  }

  var body: some View {
    Group {
      if isLoading {
        ProgressView("Connecting to Convex...")
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
    .navigationTitle("Discover")
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          isShowingSettings.toggle()
        } label: {
          Image(systemName: "gearshape")
        }
        .sheet(isPresented: $isShowingSettings) {
          SettingsView()
        }
      }
    }
    .task {
      await subscribeToTasks()
    }
    .enableInjection()
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
      isLoading = false
      tasks = result
    }
  }
}

#Preview {
  NavigationStack {
    DiscoverView()
  }
}
