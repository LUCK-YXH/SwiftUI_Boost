import UIKit

final class NoticeWindow: UIWindow {
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard let hitView = super.hitTest(point, with: event) else {
      return nil
    }

    var candidate: UIView? = hitView
    while let view = candidate {
      if view is UIControl || !(view.gestureRecognizers ?? []).isEmpty {
        return hitView
      }
      candidate = view.superview
    }

    return nil
  }
}
