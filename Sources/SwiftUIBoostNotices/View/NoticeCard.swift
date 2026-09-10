import SwiftUI

struct NoticeCard: View {
  let request: NoticeRequest
  let progress: Double
  let dismiss: () -> Void
  @GestureState private var dragOffset: CGSize = .zero

  var body: some View {
    let style = NoticeStyleResolver(request: request).style(for: icon)

    content(style: style)
      .padding(style.contentInsets)
      .foregroundStyle(style.foreground)
      .background(background(style: style))
      .overlay {
        RoundedRectangle(cornerRadius: style.cornerRadius)
          .stroke(style.border, lineWidth: 0.7)
      }
      .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius))
      .shadow(color: .black.opacity(0.14), radius: style.shadowRadius, y: 5)
      .contentShape(Rectangle())
      .offset(dragOffset)
      .onTapGesture {
        if request.options.tapToDismiss {
          dismiss()
        }
      }
      .gesture(swipeGesture)
      .accessibilityElement(children: .combine)
      .accessibilityLabel(accessibilityLabel)
  }

  @ViewBuilder
  private func content(style: NoticeStyle) -> some View {
    switch request.content {
    case .text(let text):
      Text(text)
        .font(.subheadline)
        .frame(maxWidth: .infinity, alignment: .leading)
    case .icon(let icon, let text):
      HStack(spacing: 10) {
        NoticeIconView(icon: icon, color: style.icon)
        Text(text)
          .font(.subheadline)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    case .loading(let text):
      HStack(spacing: 10) {
        ProgressView()
          .tint(style.icon)
          .frame(width: 30, height: 30)
        Text(text ?? "正在加载")
          .font(.subheadline)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    case .progress(let text):
      VStack(alignment: .leading, spacing: 9) {
        HStack(spacing: 10) {
          NoticeIconView(icon: .loading, color: style.icon)
          Text(text ?? "正在处理")
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .leading)
          Text(progress, format: .percent.precision(.fractionLength(0)))
            .font(.caption.monospacedDigit())
            .foregroundStyle(.secondary)
        }
        ProgressView(value: progress)
          .tint(style.icon)
      }
      .frame(minWidth: 190)
    case .action(let text, let title):
      HStack(spacing: 12) {
        Text(text)
          .font(.subheadline)
          .frame(maxWidth: .infinity, alignment: .leading)
        NoticeActionButton(title: title, color: style.action) {
          request.action?()
          dismiss()
        }
      }
    case .custom(let view):
      view
    }
  }

  private func background(style: NoticeStyle) -> some View {
    RoundedRectangle(cornerRadius: style.cornerRadius)
      .fill(style.background)
  }

  private var icon: NoticeIcon? {
    switch request.content {
    case .icon(let icon, _): return icon
    case .loading, .progress: return .loading
    default: return nil
    }
  }

  private var accessibilityLabel: String {
    switch request.content {
    case .text(let text), .icon(_, let text), .action(let text, _):
      return text
    case .loading(let text), .progress(let text):
      return text ?? "提示"
    case .custom:
      return "提示"
    }
  }

  private var swipeGesture: some Gesture {
    DragGesture()
      .updating($dragOffset) { value, state, _ in
        guard request.options.swipeToDismiss else { return }
        state = value.translation
      }
      .onEnded { value in
        guard request.options.swipeToDismiss else { return }
        if abs(value.translation.height) > 42 || abs(value.translation.width) > 42 {
          dismiss()
        }
      }
  }
}
