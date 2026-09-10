import SwiftUI
import UIKit

@MainActor
final class NoticeWindowPresenter {
  static let shared = NoticeWindowPresenter()

  private var windows: [String: NoticeWindow] = [:]
  private var observers: [NSObjectProtocol] = []

  private init() {}

  func install(center: NoticeCenter) {
    removeDisconnectedWindows()

    for scene in eligibleScenes {
      installWindow(for: scene, center: center)
    }

    observeSceneLifecycle(center: center)
  }

  func removeAllWindows() {
    windows.values.forEach { window in
      window.isHidden = true
      window.rootViewController = nil
    }
    windows.removeAll()
  }

  private var eligibleScenes: [UIWindowScene] {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .filter {
        $0.activationState == .foregroundActive
          || $0.activationState == .foregroundInactive
      }
  }

  private func installWindow(for scene: UIWindowScene, center: NoticeCenter) {
    let key = scene.session.persistentIdentifier
    guard windows[key] == nil else { return }

    let window = NoticeWindow(windowScene: scene)
    window.windowLevel = .alert + 1
    window.backgroundColor = .clear
    window.isOpaque = false
    window.rootViewController = UIHostingController(
      rootView: NoticeWindowRootView(center: center, hitRegions: window.hitRegions)
    )
    window.rootViewController?.view.backgroundColor = .clear
    window.isHidden = false
    windows[key] = window
  }

  private func observeSceneLifecycle(center: NoticeCenter) {
    guard observers.isEmpty else { return }

    let notificationCenter = NotificationCenter.default
    let names: [Notification.Name] = [
      UIScene.didActivateNotification,
      UIScene.willEnterForegroundNotification,
      UIScene.didDisconnectNotification,
      UIApplication.didBecomeActiveNotification,
    ]

    observers = names.map { name in
      notificationCenter.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
        Task { @MainActor in
          self?.install(center: center)
        }
      }
    }
  }

  private func removeDisconnectedWindows() {
    let activeKeys = Set(eligibleScenes.map { $0.session.persistentIdentifier })
    for key in windows.keys where !activeKeys.contains(key) {
      windows[key]?.isHidden = true
      windows[key]?.rootViewController = nil
      windows[key] = nil
    }
  }
}
