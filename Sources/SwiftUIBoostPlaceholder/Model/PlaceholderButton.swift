import SwiftUI

public struct PlaceholderButton {
  public enum Style {
    case primary
    case secondary
    case link
  }

  public var title: String
  public var style: Style
  public var action: () -> Void

  public init(
    title: String,
    style: Style = .primary,
    action: @escaping () -> Void = {}
  ) {
    self.title = title
    self.style = style
    self.action = action
  }
}

/// Convenience action model for state-based placeholder construction.
public struct PlaceholderAction {
  public var title: String
  public var role: ButtonRole?
  public var action: () -> Void

  public init(
    _ title: String,
    role: ButtonRole? = nil,
    action: @escaping () -> Void = {}
  ) {
    self.title = title
    self.role = role
    self.action = action
  }
}
