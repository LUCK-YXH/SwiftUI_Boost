import SwiftUI

struct PlaceholderButtonView: View {
  let model: PlaceholderButton

  var body: some View {
    Button(action: model.action) {
      Text(model.title)
        .font(font)
        .foregroundStyle(foreground)
        .padding(.horizontal, model.style == .link ? 4 : 24)
        .padding(.vertical, model.style == .link ? 4 : 13)
        .frame(minWidth: model.style == .link ? nil : 140)
        .background(background)
        .clipShape(Capsule())
    }
    .buttonStyle(.plain)
  }

  private var font: Font {
    switch model.style {
    case .primary, .secondary: return .system(size: 16, weight: .semibold)
    case .link: return .system(size: 15, weight: .medium)
    }
  }

  private var foreground: Color {
    switch model.style {
    case .primary: return .white
    case .secondary: return Color(red: 0.08, green: 0.09, blue: 0.1)
    case .link: return .blue
    }
  }

  @ViewBuilder private var background: some View {
    switch model.style {
    case .primary: Color.blue
    case .secondary: Color.white.opacity(0.9)
    case .link: Color.clear
    }
  }
}
