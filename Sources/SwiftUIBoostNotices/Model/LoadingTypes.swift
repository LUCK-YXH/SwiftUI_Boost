import SwiftUI

public struct LoadingConfiguration {
  public var size: CGSize
  public var background: Color
  public var tint: Color
  public var text: String?
  public var textColor: Color
  public var blocksTouches: Bool
  public init(
    size: CGSize = .init(width: 60, height: 24), background: Color = Color.black.opacity(0.5),
    tint: Color = .white, text: String? = nil, textColor: Color = .white, blocksTouches: Bool = true
  ) {
    self.size = size
    self.background = background
    self.tint = tint
    self.text = text
    self.textColor = textColor
    self.blocksTouches = blocksTouches
  }
}
