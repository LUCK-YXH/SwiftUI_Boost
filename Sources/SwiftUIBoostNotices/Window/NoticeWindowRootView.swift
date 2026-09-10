import SwiftUI

struct NoticeWindowRootView: View {
  @ObservedObject var center: NoticeCenter
  let hitRegions: NoticeHitRegions

  var body: some View {
    NoticeHost(center: center)
      .environment(\.colorScheme, .dark)
      .onPreferenceChange(NoticeHitRegionPreferenceKey.self) { frames in
        hitRegions.update(frames)
      }
  }
}
