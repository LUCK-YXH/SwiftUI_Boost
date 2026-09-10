import SwiftUI

public enum NoticeTheme {
  case light
  case dark
  case automatic
  case custom(NoticeStyle)

  /// Resolves a style without depending on the system color scheme.
  public func style() -> NoticeStyle {
    switch self {
    case .light:
      return .light
    case .dark, .automatic:
      return .dark
    case .custom(let style):
      return style
    }
  }
}
