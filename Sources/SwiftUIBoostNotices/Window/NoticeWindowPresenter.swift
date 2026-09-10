import SwiftUI
import UIKit

@MainActor
final class NoticeWindowPresenter {
  static let shared = NoticeWindowPresenter()

  private struct WindowContext {
    let window: NoticeWindow
    let insets: NoticeWindowInsets
  }

  private var contexts: [String: WindowContext] = [:]
  private var observers: [NSObjectProtocol] = []

  private init() {}

  func install(center: NoticeCenter) {
    removeDisconnectedWindows()

    for scene in eligibleScenes {
      installWindow(for: scene, center: center)
      updateInsets(for: scene)
    }

    observeSceneLifecycle(center: center)
    DispatchQueue.main.async { [weak self] in
      self?.eligibleScenes.forEach { self?.updateInsets(for: $0) }
    }
  }

  func removeAllWindows() {
    contexts.values.forEach { context in
      context.window.isHidden = true
      context.window.rootViewController = nil
    }
    contexts.removeAll()
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
    guard contexts[key] == nil else { return }

    let insets = NoticeWindowInsets()
    let window = NoticeWindow(windowScene: scene)
    window.windowLevel = .alert + 1
    window.backgroundColor = .clear
    window.isOpaque = false
    let rootViewController = NoticeWindowViewController(
      rootView: NoticeWindowRootView(
        center: center,
        insets: insets,
        hitRegions: window.hitRegions
      )
    )
    rootViewController.onLayoutChange = { [weak self] in
      self?.updateInsets(for: scene)
    }
    window.rootViewController = rootViewController
    window.rootViewController?.view.backgroundColor = .clear
    window.isHidden = false
    contexts[key] = WindowContext(window: window, insets: insets)
  }

  private func observeSceneLifecycle(center: NoticeCenter) {
    guard observers.isEmpty else { return }

    let notificationCenter = NotificationCenter.default
    let names: [Notification.Name] = [
      UIScene.didActivateNotification,
      UIScene.willEnterForegroundNotification,
      UIScene.didDisconnectNotification,
      UIApplication.didBecomeActiveNotification,
      UIDevice.orientationDidChangeNotification,
      UIWindow.didBecomeKeyNotification,
      UIWindow.didBecomeVisibleNotification,
    ]

    observers = names.map { name in
      notificationCenter.addObserver(forName: name, object: nil, queue: .main) {
        [weak self] notification in
        Task { @MainActor in
          guard let self else { return }
          self.install(center: center)
          if let scene = notification.object as? UIWindowScene {
            self.updateInsets(for: scene)
          } else {
            self.eligibleScenes.forEach { self.updateInsets(for: $0) }
          }
        }
      }
    }
  }

  private func updateInsets(for scene: UIWindowScene) {
    guard let context = contexts[scene.session.persistentIdentifier] else { return }
    let underlyingWindows = scene.windows.filter { $0 !== context.window && !$0.isHidden }
    let referenceWindow = underlyingWindows.first(where: \.isKeyWindow) ?? underlyingWindows.first

    let safeAreaInsets = context.window.safeAreaInsets
    var top = safeAreaInsets.top
    var bottom = safeAreaInsets.bottom

    if let referenceWindow {
      let bars = visibleBars(in: referenceWindow)
      top = max(top, bars.top)
      bottom = max(bottom, bars.bottom)
    }

    context.insets.update(top: top - safeAreaInsets.top, bottom: bottom - safeAreaInsets.bottom)
  }

  private func visibleBars(in window: UIWindow) -> (top: CGFloat, bottom: CGFloat) {
    let bounds = window.bounds
    var top: CGFloat = 0
    var bottom: CGFloat = 0

    for view in allSubviews(of: window) {
      guard !view.isHidden, view.alpha > 0.01 else { continue }
      let frame = view.convert(view.bounds, to: window)
      guard frame.width > 0, frame.height > 0 else { continue }

      if view is UINavigationBar {
        top = max(top, max(0, frame.maxY))
      }
      if view is UITabBar {
        bottom = max(bottom, max(0, bounds.height - frame.minY))
      }
    }

    return (top, bottom)
  }

  private func allSubviews(of view: UIView) -> [UIView] {
    view.subviews.flatMap { [$0] + allSubviews(of: $0) }
  }

  private func removeDisconnectedWindows() {
    let activeKeys = Set(eligibleScenes.map { $0.session.persistentIdentifier })
    for key in contexts.keys where !activeKeys.contains(key) {
      contexts[key]?.window.isHidden = true
      contexts[key]?.window.rootViewController = nil
      contexts[key] = nil
    }
  }
}
