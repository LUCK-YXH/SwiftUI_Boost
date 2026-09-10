import SwiftUI

public struct NoticeStyle {
  public var background: Color
  public var foreground: Color
  public var icon: Color
  public var action: Color
  public var border: Color
  public var cornerRadius: CGFloat
  public var contentInsets: EdgeInsets
  public var shadowRadius: CGFloat
  public var usesMaterial: Bool
  public var maxWidth: CGFloat

  public init(
    background: Color = .black.opacity(0.88),
    foreground: Color = .white,
    icon: Color = .white,
    action: Color = .white,
    border: Color = .clear,
    cornerRadius: CGFloat = 14,
    contentInsets: EdgeInsets = .init(top: 12, leading: 14, bottom: 12, trailing: 14),
    shadowRadius: CGFloat = 12,
    usesMaterial: Bool = false,
    maxWidth: CGFloat = 360
  ) {
    self.background = background
    self.foreground = foreground
    self.icon = icon
    self.action = action
    self.border = border
    self.cornerRadius = cornerRadius
    self.contentInsets = contentInsets
    self.shadowRadius = shadowRadius
    self.usesMaterial = usesMaterial
    self.maxWidth = maxWidth
  }

  public static let light = NoticeStyle(
    background: Color(red: 0.15, green: 0.16, blue: 0.19),
    foreground: .white,
    icon: .white,
    action: Color(red: 0.38, green: 0.68, blue: 1.0),
    border: Color.white.opacity(0.12),
    shadowRadius: 14,
    usesMaterial: false
  )

  public static let dark = NoticeStyle(
    background: Color(red: 0.15, green: 0.16, blue: 0.19),
    foreground: .white,
    icon: .white,
    action: Color(red: 0.38, green: 0.68, blue: 1.0),
    border: Color.white.opacity(0.12),
    shadowRadius: 14,
    usesMaterial: false
  )
}

public enum NoticeSemanticColor {
  case neutral
  case success
  case failure
  case warning
  case information
  case loading

  public var color: Color {
    switch self {
    case .neutral: return .secondary
    case .success: return .green
    case .failure: return .red
    case .warning: return .orange
    case .information: return .blue
    case .loading: return .accentColor
    }
  }
}
