import SwiftUI

@MainActor public final class NoticeBuilder {
  private let text: String
  private var options = NoticePartialOptions()
  private var icon: NoticeIcon?
  private var action: (() -> Void)?
  private var onDismiss: (() -> Void)?

  public init(_ text: String) { self.text = text }
  public func icon(_ icon: NoticeIcon) -> NoticeBuilder {
    self.icon = icon
    return self
  }
  public func placement(_ value: NoticePlacement) -> NoticeBuilder {
    options.placement = value
    return self
  }
  public func duration(_ value: NoticeLifetime) -> NoticeBuilder {
    options.lifetime = value
    return self
  }
  public func animation(_ value: NoticePresentation) -> NoticeBuilder {
    options.presentation = value
    return self
  }
  public func queue(_ value: NoticeQueuePolicy) -> NoticeBuilder {
    options.queue = value
    return self
  }
  public func theme(_ value: NoticeTheme) -> NoticeBuilder {
    options.theme = value
    return self
  }
  public func tapToDismiss(_ value: Bool) -> NoticeBuilder {
    options.tapToDismiss = value
    return self
  }
  public func swipeToDismiss(_ value: Bool) -> NoticeBuilder {
    options.swipeToDismiss = value
    return self
  }
  public func onAction(_ handler: @escaping () -> Void) -> NoticeBuilder {
    action = handler
    return self
  }
  public func onDismiss(_ handler: @escaping () -> Void) -> NoticeBuilder {
    onDismiss = handler
    return self
  }

  @discardableResult public func show() -> NoticeToken { show(in: NoticeCenter.shared) }

  @discardableResult public func show(in center: NoticeCenter) -> NoticeToken {
    let content: NoticeContent = icon.map { .icon($0, text) } ?? .text(text)
    return center.present(
      center.configuration.request(
        content: content, options: options, action: action, onDismiss: onDismiss))
  }
}
