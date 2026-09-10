import UIKit

final class NoticeWindow: UIWindow {
  let hitRegions = NoticeHitRegions()

  // SwiftUI 把手势装在承载视图上而非具体子视图，无法靠命中视图自身推断可交互性，
  // 只能按 notice 卡片上报的实际矩形判断是否接管触摸。
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard hitRegions.contains(point) else { return nil }
    return super.hitTest(point, with: event)
  }
}
