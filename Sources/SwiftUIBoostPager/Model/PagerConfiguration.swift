import SwiftUI

public enum PagerAxis { case horizontal, vertical }
public enum PagerDirection { case free, forwardOnly, backwardOnly }
public struct PagerConfiguration {
  public var axis: PagerAxis = .vertical
  public var direction: PagerDirection = .free
  public var spacing: CGFloat = 12
  public var peek: CGFloat = 72
  public var contentInset: EdgeInsets = .init()
  public var bounces = true
  public var initialIndex = 0
  public init() {}
}
