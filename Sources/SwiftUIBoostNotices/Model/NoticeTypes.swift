import SwiftUI

public enum NoticeIcon: Equatable {
  case success
  case failure
  case warning
  case information
  case loading
}

public enum NoticeContent {
  case text(String)
  case icon(NoticeIcon, String)
  case loading(String?)
  case progress(String?)
  case action(String, title: String)
  case custom(AnyView)
}

public enum NoticePlacement: Equatable { case top, center, bottom }
public enum NoticeLifetime: Equatable {
  case automatic
  case seconds(TimeInterval)
  case persistent
}
public enum NoticePresentation: Equatable { case fade, slide, scale, none }
public enum NoticeQueuePolicy: Equatable { case queue, replace, stack }

public struct NoticePartialOptions {
  public var placement: NoticePlacement?
  public var lifetime: NoticeLifetime?
  public var presentation: NoticePresentation?
  public var theme: NoticeTheme?
  public var queue: NoticeQueuePolicy?
  public var tapToDismiss: Bool?
  public var swipeToDismiss: Bool?
  public init() {}
}

public struct NoticeConfiguration {
  public var defaultPlacement: NoticePlacement = .bottom
  public var defaultLifetime: NoticeLifetime = .automatic
  public var defaultPresentation: NoticePresentation = .slide
  public var defaultTheme: NoticeTheme = .dark
  public var defaultQueue: NoticeQueuePolicy = .queue
  public var cornerRadius: CGFloat = 12
  public var maxWidth: CGFloat = 320
  public var tapToDismiss = true
  public var swipeToDismiss = false
  public init() {}

  public func resolve(_ options: NoticePartialOptions) -> NoticeResolvedOptions {
    NoticeResolvedOptions(
      placement: options.placement ?? defaultPlacement,
      lifetime: options.lifetime ?? defaultLifetime,
      presentation: options.presentation ?? defaultPresentation,
      theme: options.theme ?? defaultTheme,
      queue: options.queue ?? defaultQueue,
      tapToDismiss: options.tapToDismiss ?? tapToDismiss,
      swipeToDismiss: options.swipeToDismiss ?? swipeToDismiss,
      cornerRadius: cornerRadius,
      maxWidth: maxWidth
    )
  }
}

public struct NoticeResolvedOptions {
  public let placement: NoticePlacement
  public let lifetime: NoticeLifetime
  public let presentation: NoticePresentation
  public let theme: NoticeTheme
  public let queue: NoticeQueuePolicy
  public let tapToDismiss: Bool
  public let swipeToDismiss: Bool
  public let cornerRadius: CGFloat
  public let maxWidth: CGFloat
}

public struct NoticeRequest: Identifiable {
  public let id: UUID
  public var content: NoticeContent
  public var options: NoticeResolvedOptions
  public var action: (() -> Void)?
  public var onDismiss: (() -> Void)?

  public init(
    content: NoticeContent,
    options: NoticeResolvedOptions,
    action: (() -> Void)? = nil,
    onDismiss: (() -> Void)? = nil
  ) {
    self.id = UUID()
    self.content = content
    self.options = options
    self.action = action
    self.onDismiss = onDismiss
  }
}

extension NoticeConfiguration {
  public func request(
    content: NoticeContent,
    options: NoticePartialOptions = .init(),
    action: (() -> Void)? = nil,
    onDismiss: (() -> Void)? = nil
  ) -> NoticeRequest {
    NoticeRequest(content: content, options: resolve(options), action: action, onDismiss: onDismiss)
  }
}
