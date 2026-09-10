import SwiftUI

struct NoticeActionButton: View {
  let title: String
  let color: Color
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(color)
        .lineLimit(1)
    }
    .buttonStyle(.plain)
    .accessibilityAddTraits(.isButton)
  }
}
