import SwiftUI

/// Visual tuning for the Buzzme-style skeleton loading treatment.
public struct SkeletonConfiguration {
  /// The neutral surface behind the moving highlight.
  public var base: Color = Color(.systemGray5)
  /// The soft, low-contrast highlight that travels across placeholder content.
  public var highlight: Color = Color.white.opacity(0.62)
  public var cornerRadius: CGFloat = 8
  public var animationDuration: Double = 1.2
  /// Width of the highlight as a fraction of the placeholder's width.
  public var shimmerWidthRatio: CGFloat = 0.42

  public init() {}

  /// Defaults used by Buzzme-like feed and card placeholders.
  public static var buzzme: SkeletonConfiguration { .init() }

  /// Returns a repeating horizontal shimmer phase in the range `-1...1`.
  func shimmerPhase(at time: TimeInterval) -> CGFloat {
    let duration = max(animationDuration, 0.1)
    let progress = CGFloat(time.truncatingRemainder(dividingBy: duration) / duration)
    return progress * 2 - 1
  }
}
