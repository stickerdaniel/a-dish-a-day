//
//  ExportManager.swift
//  calendar
//
//  Created by Daniel Sticker on 16.01.25.
//  Helper to export / share calendar

import SwiftUI
import UIKit

struct ExportManager {
  /// Encode calendar and return URL for the JSON file
  static func exportCalendar(_ calendar: CalendarModel) -> URL? {
    return CalendarSerialization.encodeCalendar(calendar)
  }

  /// Present share sheet for the provided file URL
  static func shareFile(url: URL) {
    _ = share(items: [url])
  }

  /// Helper function to open share sheet
  @discardableResult
  private static func share(items: [Any], excludedActivityTypes: [UIActivity.ActivityType]? = nil)
    -> Bool
  {
    guard let rootViewController = getRootViewController() else {
      return false
    }

    let activityViewController = UIActivityViewController(
      activityItems: items, applicationActivities: nil)
    activityViewController.excludedActivityTypes = excludedActivityTypes

    if let popoverController = activityViewController.popoverPresentationController {
      popoverController.sourceView = rootViewController.view
      popoverController.sourceRect = CGRect(
        x: rootViewController.view.bounds.midX,
        y: rootViewController.view.bounds.midY,
        width: 0,
        height: 0
      )
      popoverController.permittedArrowDirections = []
    }

    rootViewController.present(activityViewController, animated: true)
    return true
  }

  /// Retrieve the root view controller from the active window scene
  private static func getRootViewController() -> UIViewController? {
    guard
      let scene = UIApplication.shared.connectedScenes.first(where: {
        $0.activationState == .foregroundActive
      }) as? UIWindowScene,
      let window = scene.windows.first(where: { $0.isKeyWindow })
    else {
      return nil
    }
    return window.rootViewController
  }
}
