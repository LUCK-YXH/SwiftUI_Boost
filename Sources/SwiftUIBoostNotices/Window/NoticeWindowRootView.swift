import SwiftUI

struct NoticeWindowRootView: View {
  @ObservedObject var center: NoticeCenter
  @ObservedObject var insets: NoticeWindowInsets
  let hitRegions: NoticeHitRegions

  var body: some View {
    NoticeHost(center: center, additionalInsets: insets.value)
      .environment(\.colorScheme, .dark)
      .onPreferenceChange(NoticeHitRegionPreferenceKey.self) { frames in
        hitRegions.update(frames)
      }
  }
}
