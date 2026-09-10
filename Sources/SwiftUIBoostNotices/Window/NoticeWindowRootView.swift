import SwiftUI

struct NoticeWindowRootView: View {
  @ObservedObject var center: NoticeCenter
  @ObservedObject var insets: NoticeWindowInsets

  var body: some View {
    NoticeHost(center: center, additionalInsets: insets.value)
      .background(Color.clear)
      .environment(\.colorScheme, .dark)
  }
}
