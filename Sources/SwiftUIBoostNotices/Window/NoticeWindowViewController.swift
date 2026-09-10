import SwiftUI

final class NoticeWindowViewController: UIHostingController<NoticeWindowRootView> {
  var onLayoutChange: (() -> Void)?

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    onLayoutChange?()
  }

  override func viewSafeAreaInsetsDidChange() {
    super.viewSafeAreaInsetsDidChange()
    onLayoutChange?()
  }
}
