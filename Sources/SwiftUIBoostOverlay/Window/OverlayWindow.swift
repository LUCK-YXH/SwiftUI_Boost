#if canImport(UIKit)
import SwiftUI
import UIKit

@MainActor
public final class OverlayWindowPresenter {
  public static let shared = OverlayWindowPresenter()

  private var window: UIWindow?
  private weak var coordinator: OverlayCoordinator?

  private init() {}

  public func show(_ coordinator: OverlayCoordinator, in scene: UIWindowScene? = nil) {
    dismiss()
    self.coordinator = coordinator

    let targetScene = scene ?? UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .first(where: { $0.activationState == .foregroundActive })
    guard let targetScene else { return }

    let window = UIWindow(windowScene: targetScene)
    window.windowLevel = .alert + 1
    window.backgroundColor = .clear
    window.rootViewController = UIHostingController(rootView: OverlayHost(coordinator: coordinator))
    window.rootViewController?.view.backgroundColor = .clear
    window.isHidden = false
    self.window = window
  }

  public func dismiss() {
    window?.isHidden = true
    window?.rootViewController = nil
    window = nil
    coordinator = nil
  }
}

extension View {
  public func overlayWindowHost(_ coordinator: OverlayCoordinator) -> some View {
    onAppear {
      OverlayWindowPresenter.shared.show(coordinator)
    }
    .onDisappear {
      OverlayWindowPresenter.shared.dismiss()
    }
  }
}
#endif
