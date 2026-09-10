import UIKit

/// 窗口坐标系下的可用内容边界，用于把 Toast 对齐到导航栏和 Tab 栏，而不是安全区。
struct NoticeBarMetrics {
  let topBoundary: CGFloat
  let bottomBoundary: CGFloat
  let navigationBarMaxY: CGFloat
  let tabBarMinY: CGFloat
  let windowHeight: CGFloat

  static var current: NoticeBarMetrics {
    UIWindow.noticeReferenceWindow?.noticeBarMetrics
      ?? NoticeBarMetrics(
        topBoundary: 0,
        bottomBoundary: .greatestFiniteMagnitude,
        navigationBarMaxY: 0,
        tabBarMinY: .greatestFiniteMagnitude,
        windowHeight: 0
      )
  }
}

extension UIWindow {
  static var noticeReferenceWindow: UIWindow? {
    let candidates = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .filter {
        $0.activationState == .foregroundActive
          || $0.activationState == .foregroundInactive
      }
      .flatMap(\.windows)
      .filter { !$0.isHidden && !($0 is NoticeWindow) }

    return candidates.first(where: \.isKeyWindow) ?? candidates.first
  }

  var noticeBarMetrics: NoticeBarMetrics {
    var navigationBarMaxY: CGFloat = 0
    var tabBarMinY = bounds.maxY

    for view in noticeVisibleSubviews {
      let frame = view.convert(view.bounds, to: self)
      guard frame.width > 0, frame.height > 0 else { continue }

      if view is UINavigationBar {
        navigationBarMaxY = max(navigationBarMaxY, frame.maxY)
      }
      if view is UITabBar {
        tabBarMinY = min(tabBarMinY, frame.minY)
      }
    }

    return NoticeBarMetrics(
      topBoundary: max(navigationBarMaxY, safeAreaInsets.top),
      bottomBoundary: min(tabBarMinY, bounds.maxY - safeAreaInsets.bottom),
      navigationBarMaxY: navigationBarMaxY,
      tabBarMinY: tabBarMinY,
      windowHeight: bounds.height
    )
  }

  private var noticeVisibleSubviews: [UIView] {
    func collect(_ view: UIView) -> [UIView] {
      view.subviews
        .filter { !$0.isHidden && $0.alpha > 0.01 }
        .flatMap { [$0] + collect($0) }
    }
    return collect(self)
  }
}
