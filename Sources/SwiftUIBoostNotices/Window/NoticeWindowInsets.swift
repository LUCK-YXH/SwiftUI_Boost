import SwiftUI

@MainActor
final class NoticeWindowInsets: ObservableObject {
  @Published private(set) var value = NoticeHostInsets()

  func update(top: CGFloat, bottom: CGFloat) {
    let next = NoticeHostInsets(top: max(top, 0), bottom: max(bottom, 0))
    guard next.top != value.top || next.bottom != value.bottom else { return }
    value = next
  }
}
