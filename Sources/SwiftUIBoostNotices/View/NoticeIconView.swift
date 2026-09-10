import SwiftUI

struct NoticeIconView: View {
  let icon: NoticeIcon
  let color: Color

  var body: some View {
    Image(systemName: icon.systemName)
      .font(.system(size: 18, weight: .semibold))
      .foregroundStyle(color)
      .frame(width: 30, height: 30)
      .background(color.opacity(0.14), in: Circle())
      .accessibilityHidden(true)
  }
}

extension NoticeIcon {
  var systemName: String {
    switch self {
    case .success: return "checkmark"
    case .failure: return "xmark"
    case .warning: return "exclamationmark"
    case .information: return "info"
    case .loading: return "ellipsis"
    }
  }
}
