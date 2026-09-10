import SwiftUI

struct NoticeStyleResolver {
  let request: NoticeRequest
  var baseStyle: NoticeStyle {
    request.options.theme.style()
  }

  func style(for icon: NoticeIcon?) -> NoticeStyle {
    var style = baseStyle
    guard let icon else { return style }
    style.icon = semanticColor(for: icon)
    style.action = semanticColor(for: icon)
    return style
  }

  private func semanticColor(for icon: NoticeIcon) -> Color {
    switch icon {
    case .success: return .green
    case .failure: return .red
    case .warning: return .orange
    case .information: return .blue
    case .loading: return .accentColor
    }
  }
}
