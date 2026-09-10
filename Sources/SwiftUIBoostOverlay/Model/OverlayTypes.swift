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
    title: String,
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

  /// Compatibility initializer for the original `message` spelling.
  public init(
    style: OverlayStyle = .alert,
    title: String,
    message: String? = nil,
    actions: [OverlayAction] = [],
    dismissOnBackgroundTap: Bool = true
  ) {
    self.init(
      style: style,
      title: title,
      subtitle: message,
      actions: actions,
      dismissOnBackgroundTap: dismissOnBackgroundTap
    )
  }

  public static func custom<Content: View>(
    style: OverlayStyle = .custom,
    icon: OverlayIcon? = nil,
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
