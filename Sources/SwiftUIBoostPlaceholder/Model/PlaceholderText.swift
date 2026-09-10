import SwiftUI

public struct PlaceholderText {
  public var value: String
  public var font: Font?
  public var color: Color?

  public init(_ value: String, font: Font? = nil, color: Color? = nil) {
    self.value = value
    self.font = font
    self.color = color
  }
}
