import CoreGraphics

// 只在主线程读写（hitTest 与 onPreferenceChange），故按 @unchecked Sendable 处理。
final class NoticeHitRegions: @unchecked Sendable {
  private(set) var frames: [CGRect] = []

  func update(_ frames: [CGRect]) {
    self.frames = frames
  }

  func contains(_ point: CGPoint) -> Bool {
    frames.contains { $0.contains(point) }
  }
}
