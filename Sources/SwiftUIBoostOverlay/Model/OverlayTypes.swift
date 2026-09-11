import SwiftUI

public enum OverlayStyle: Equatable {
  case alert
  case actionSheet
  case hero
  case custom
}

public enum OverlayActionStyle: Equatable {
  case primary
  case secondary
  case destructive
  case cancel
  case plain
}

public enum OverlayButtonLayout: Equatable {
  case automatic
  case vertical
  case horizontal
}

public enum OverlayIcon {
  case system(String)
  case image(Image)
  case custom(AnyView)

  public static func view<Content: View>(
    @ViewBuilder _ content: () -> Content
  ) -> OverlayIcon {
    .custom(AnyView(content()))
  }
}

/// 「趴」在弹窗顶沿的动画形象（吉祥物 / 插画）。
///
/// 形象整体渲染在卡片上方，靠 `overhang` 露出上半身、其余压在卡片顶部边缘，
/// 形成「探出头 / 趴在窗口上」的效果，并始终固定在卡片顶沿。
public struct OverlayMascot {
  public enum Content {
    case system(String)
    case image(Image)
    case view(AnyView)
  }

  /// 形象在卡片横向上的落点。
  public enum Anchor: Equatable {
    case leading
    case center
    case trailing
  }

  public var content: Content
  public var size: CGSize
  public var anchor: Anchor
  /// 露出卡片顶沿的高度（越大越「站得高」；其余 `size.height - overhang` 压在卡片上）。
  public var overhang: CGFloat
  /// 距卡片左 / 右边缘的横向内边距，仅 `.leading` / `.trailing` 生效。
  public var horizontalInset: CGFloat
  /// 兼容旧版本 API；形象当前始终固定，不播放位置、缩放或呼吸动画。
  public var animated: Bool

  public init(
    content: Content,
    size: CGSize = CGSize(width: 104, height: 104),
    anchor: Anchor = .center,
    overhang: CGFloat? = nil,
    horizontalInset: CGFloat = 20,
    animated: Bool = false
  ) {
    self.content = content
    self.size = size
    self.anchor = anchor
    self.overhang = overhang ?? size.height * 0.6
    self.horizontalInset = horizontalInset
    self.animated = animated
  }

  /// 压在卡片上、需要为其预留的顶部空间。
  public var restingHeight: CGFloat { max(0, size.height - overhang) }

  public static func system(
    _ name: String,
    size: CGSize = CGSize(width: 104, height: 104),
    anchor: Anchor = .center
  ) -> OverlayMascot {
    OverlayMascot(content: .system(name), size: size, anchor: anchor)
  }

  public static func image(
    _ image: Image,
    size: CGSize = CGSize(width: 104, height: 104),
    anchor: Anchor = .center
  ) -> OverlayMascot {
    OverlayMascot(content: .image(image), size: size, anchor: anchor)
  }

  public static func view<V: View>(
    size: CGSize = CGSize(width: 104, height: 104),
    anchor: Anchor = .center,
    @ViewBuilder _ content: () -> V
  ) -> OverlayMascot {
    OverlayMascot(content: .view(AnyView(content())), size: size, anchor: anchor)
  }
}

public enum OverlayDismissReason: Equatable {
  case background
  case action
  case closeButton
  case swipe
  case programmatic
  case replaced
}

public enum OverlayTransition {
  case fade
  case scale
  case slide
  case slideFromBottom
  case none
  case custom(AnyTransition)
}

public struct OverlayAction: Identifiable {
  public let id = UUID()
  public var title: String
  public var subtitle: String?
  public var style: OverlayActionStyle
  public var role: ButtonRole?
  public var dismissesOverlay: Bool
  public var action: (() -> Void)?

  public init(
    _ title: String,
    role: ButtonRole? = nil,
    action: (() -> Void)? = nil
  ) {
    let style: OverlayActionStyle
    switch role {
    case .cancel:
      style = .cancel
    case .destructive:
      style = .destructive
    default:
      style = .primary
    }
    self.init(title, style: style, role: role, action: action)
  }

  public init(
    _ title: String,
    subtitle: String? = nil,
    style: OverlayActionStyle = .primary,
    role: ButtonRole? = nil,
    dismissesOverlay: Bool = true,
    action: (() -> Void)? = nil
  ) {
    self.title = title
    self.subtitle = subtitle
    self.style = style
    self.role = role ?? Self.defaultRole(for: style)
    self.dismissesOverlay = dismissesOverlay
    self.action = action
  }

  private static func defaultRole(for style: OverlayActionStyle) -> ButtonRole? {
    switch style {
    case .cancel:
      return .cancel
    case .destructive:
      return .destructive
    case .primary, .secondary, .plain:
      return nil
    }
  }
}

public struct OverlayRequest: Identifiable {
  public let id = UUID()
  public var style: OverlayStyle
  public var icon: OverlayIcon?
  /// Hero 图标徽章底色；`nil` 时使用主题默认色。仅 `.hero` 样式生效。
  public var iconBackground: Color?
  /// 趴在弹窗顶沿的动画形象；`nil` 时不显示。三种样式通用。
  public var mascot: OverlayMascot?
  public var title: String
  public var subtitle: String?
  public var actions: [OverlayAction]
  public var buttonLayout: OverlayButtonLayout
  public var dismissOnBackgroundTap: Bool
  public var showsCloseButton: Bool
  public var allowsSwipeToDismiss: Bool
  public var dismissOnAction: Bool
  public var transition: OverlayTransition?
  public var customContent: AnyView?
  public var onDismiss: ((OverlayDismissReason) -> Void)?

  public init(
    style: OverlayStyle = .alert,
    icon: OverlayIcon? = nil,
    iconBackground: Color? = nil,
    mascot: OverlayMascot? = nil,
    title: String = "",
    subtitle: String? = nil,
    actions: [OverlayAction] = [],
    buttonLayout: OverlayButtonLayout = .automatic,
    dismissOnBackgroundTap: Bool = true,
    showsCloseButton: Bool = false,
    allowsSwipeToDismiss: Bool? = nil,
    dismissOnAction: Bool = true,
    transition: OverlayTransition? = nil,
    onDismiss: ((OverlayDismissReason) -> Void)? = nil
  ) {
    self.style = style
    self.icon = icon
    self.iconBackground = iconBackground
    self.mascot = mascot
    self.title = title
    self.subtitle = subtitle
    self.actions = actions
    self.buttonLayout = buttonLayout
    self.dismissOnBackgroundTap = dismissOnBackgroundTap
    self.showsCloseButton = showsCloseButton
    self.allowsSwipeToDismiss = allowsSwipeToDismiss ?? (style == .actionSheet)
    self.dismissOnAction = dismissOnAction
    self.transition = transition
    self.customContent = nil
    self.onDismiss = onDismiss
  }

  public static func custom<Content: View>(
    style: OverlayStyle = .custom,
    icon: OverlayIcon? = nil,
    iconBackground: Color? = nil,
    mascot: OverlayMascot? = nil,
    title: String = "",
    subtitle: String? = nil,
    actions: [OverlayAction] = [],
    buttonLayout: OverlayButtonLayout = .automatic,
    dismissOnBackgroundTap: Bool = true,
    showsCloseButton: Bool = false,
    allowsSwipeToDismiss: Bool? = nil,
    dismissOnAction: Bool = true,
    transition: OverlayTransition? = nil,
    onDismiss: ((OverlayDismissReason) -> Void)? = nil,
    @ViewBuilder content: () -> Content
  ) -> OverlayRequest {
    var request = OverlayRequest(
      style: style,
      icon: icon,
      iconBackground: iconBackground,
      mascot: mascot,
      title: title,
      subtitle: subtitle,
      actions: actions,
      buttonLayout: buttonLayout,
      dismissOnBackgroundTap: dismissOnBackgroundTap,
      showsCloseButton: showsCloseButton,
      allowsSwipeToDismiss: allowsSwipeToDismiss,
      dismissOnAction: dismissOnAction,
      transition: transition,
      onDismiss: onDismiss
    )
    request.customContent = AnyView(content())
    return request
  }

  public var message: String? {
    get { subtitle }
    set { subtitle = newValue }
  }
}
