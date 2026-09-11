#if canImport(UIKit)
import SwiftUI
import UIKit

/// Veil 式一行调用的全局弹窗入口（对齐系统 `UIAlertController` 的扩展性）。
/// 首次调用时在独立 `UIWindow` 上安装一个共享 `OverlayCoordinator`，业务侧无需手动布线。
///
/// ```swift
/// Overlay.confirm(title: "Block Maya?", message: "She won't be able to reach you.",
///                 confirmTitle: "Block", destructive: true) { blockUser() }
///
/// Overlay.actionSheet(actions: [
///   .init("View profile") { … },
///   .init("Block Maya", subtitle: "She won't be able to reach you", style: .destructive) { … },
///   .init("Cancel", style: .cancel)     // 自动渲染为底部独立 Cancel 卡
/// ])
///
/// Overlay.hero(icon: .system("bell.badge"), iconBackground: Color(red: 0.98, green: 0.95, blue: 0.88),
///              title: "Turn on alerts?", message: "…",
///              primaryTitle: "Allow", cancelTitle: "Not now") { requestPush() }
/// ```
///
/// 注意：`Overlay` 与 `overlayWindowHost(_:)` 共用同一个 `OverlayWindowPresenter`，二选一使用。
@MainActor
public enum Overlay {
  /// 全局共享协调器，可用于观察 / 手动 `present` / `dismiss`。
  public static let coordinator = OverlayCoordinator()

  private static var theme: OverlayTheme = .default
  private static var isInstalled = false

  /// 自定义全局主题（在首次展示前调用；若已安装会重装窗口以生效）。
  public static func configure(theme: OverlayTheme) {
    self.theme = theme
    if isInstalled {
      isInstalled = false
      install()
    }
  }

  /// 展示任意 `OverlayRequest`。
  public static func present(_ request: OverlayRequest) {
    install()
    coordinator.present(request)
  }

  /// 关闭当前弹窗。
  public static func dismiss(reason: OverlayDismissReason = .programmatic) {
    coordinator.dismiss(reason: reason)
  }

  /// 居中 alert：标题 + 说明 + 一组按钮（cancel 自动置左，≤2 横排）。
  public static func alert(title: String?, message: String? = nil, actions: [OverlayAction]) {
    present(OverlayRequest(
      style: .alert,
      title: title ?? "",
      subtitle: message,
      actions: actions,
      dismissOnBackgroundTap: false
    ))
  }

  /// 底部 action sheet：一列行（支持副标题 / destructive），`.cancel` 自动成为独立 Cancel 卡。
  public static func actionSheet(title: String? = nil, message: String? = nil, actions: [OverlayAction]) {
    present(OverlayRequest(
      style: .actionSheet,
      title: title ?? "",
      subtitle: message,
      actions: actions,
      dismissOnBackgroundTap: true
    ))
  }

  /// 「取消 / 确认」两键 alert 便捷封装。
  public static func confirm(
    title: String?,
    message: String?,
    confirmTitle: String,
    cancelTitle: String = "Cancel",
    destructive: Bool = false,
    onConfirm: @escaping () -> Void
  ) {
    alert(title: title, message: message, actions: [
      OverlayAction(cancelTitle, style: .cancel),
      OverlayAction(confirmTitle, style: destructive ? .destructive : .primary, action: onConfirm)
    ])
  }

  /// 图标徽章弹窗：顶部图标 + 标题 + 说明 + 主按钮(填充) + 次按钮(纯文字)。
  public static func hero(
    icon: OverlayIcon?,
    iconBackground: Color? = nil,
    title: String,
    message: String? = nil,
    primaryTitle: String,
    cancelTitle: String,
    onPrimary: @escaping () -> Void
  ) {
    present(OverlayRequest(
      style: .hero,
      icon: icon,
      iconBackground: iconBackground,
      title: title,
      subtitle: message,
      actions: [
        OverlayAction(cancelTitle, style: .cancel),
        OverlayAction(primaryTitle, style: .primary, action: onPrimary)
      ],
      dismissOnBackgroundTap: false
    ))
  }

  private static func install() {
    guard !isInstalled else { return }
    OverlayWindowPresenter.shared.show(coordinator, theme: theme)
    // 仅在窗口成功挂载（存在前台场景）时标记安装，否则下次 present 重试。
    isInstalled = OverlayWindowPresenter.shared.isPresenting
  }
}
#endif
