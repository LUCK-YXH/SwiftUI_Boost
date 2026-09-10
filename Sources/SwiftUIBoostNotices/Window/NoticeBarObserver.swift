import SwiftUI
import UIKit

final class NoticeBarObserver: ObservableObject {
  static let shared = NoticeBarObserver()

  @Published private(set) var metrics: NoticeBarMetrics = .empty

  private var observers: [NSObjectProtocol] = []

  private init() {
    let names: [Notification.Name] = [
      UIApplication.didBecomeActiveNotification,
      UIDevice.orientationDidChangeNotification,
      UIWindow.didBecomeKeyNotification,
    ]

    observers = names.map { name in
      NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { _ in
        Task { @MainActor in
          NoticeBarObserver.shared.refresh()
        }
      }
    }
  }

  @MainActor
  func refresh() {
    let next = NoticeBarMetrics.current
    guard next != metrics else { return }
    metrics = next
  }
}
