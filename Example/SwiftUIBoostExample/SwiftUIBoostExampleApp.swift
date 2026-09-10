import SwiftUI
import SwiftUIBoostNotices

@main
struct SwiftUIBoostExampleApp: App {
  @StateObject private var notices = NoticeCenter.shared

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(notices)
        .noticeWindowHost(notices)
    }
  }
}
