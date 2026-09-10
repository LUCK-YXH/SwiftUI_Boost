import SwiftUI

public struct NoticeWindowModifier: ViewModifier {
  let center: NoticeCenter

  public func body(content: Content) -> some View {
    content
      .onAppear {
        NoticeWindowPresenter.shared.install(center: center)
      }
  }
}

extension View {
  public func noticeWindowHost(_ center: NoticeCenter) -> some View {
    modifier(NoticeWindowModifier(center: center))
  }
}
