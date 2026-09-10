import SwiftUI

@MainActor public enum NoticeService {
  public static var configuration: NoticeConfiguration {
    get { NoticeCenter.shared.configuration }
    set { NoticeCenter.shared.configuration = newValue }
  }
  private static func present(
    content: NoticeContent,
    options: NoticePartialOptions = .init(),
    action: (() -> Void)? = nil,
    onDismiss: (() -> Void)? = nil
  ) -> NoticeToken {
    return NoticeCenter.shared.present(
      configuration.request(
        content: content, options: options, action: action, onDismiss: onDismiss)
    )
  }

  @discardableResult public static func text(_ value: String) -> NoticeToken {
    present(content: .text(value))
  }
  @discardableResult public static func success(_ value: String) -> NoticeToken {
    present(content: .icon(.success, value))
  }
  @discardableResult public static func failure(_ value: String) -> NoticeToken {
    present(content: .icon(.failure, value))
  }
  @discardableResult public static func warning(_ value: String) -> NoticeToken {
    present(content: .icon(.warning, value))
  }
  @discardableResult public static func information(_ value: String) -> NoticeToken {
    present(content: .icon(.information, value))
  }
  @discardableResult public static func loading(_ value: String? = nil) -> NoticeToken {
    var options = NoticePartialOptions()
    options.lifetime = .persistent
    return present(content: .loading(value), options: options)
  }
  @discardableResult public static func progress(_ value: String? = nil) -> NoticeToken {
    var options = NoticePartialOptions()
    options.lifetime = .persistent
    return present(content: .progress(value), options: options)
  }
  @discardableResult public static func action(
    _ value: String, title: String, handler: @escaping () -> Void
  ) -> NoticeToken {
    var options = NoticePartialOptions()
    options.lifetime = .seconds(4)
    return present(content: .action(value, title: title), options: options, action: handler)
  }
  @discardableResult public static func custom<Content: View>(
    _ content: Content, placement: NoticePlacement = .center, lifetime: NoticeLifetime = .seconds(3)
  ) -> NoticeToken {
    var options = NoticePartialOptions()
    options.placement = placement
    options.lifetime = lifetime
    return present(
      content: .custom(AnyView(content)),
      options: options
    )
  }
  public static func make(_ text: String) -> NoticeBuilder { NoticeBuilder(text) }
  public static func dismiss() { NoticeCenter.shared.dismissCurrent() }
  public static func dismissAll() { NoticeCenter.shared.dismissAll() }
}

@MainActor extension NoticeService {
  public static func task<T>(loading text: String, _ operation: () async throws -> T) async rethrows
    -> T
  {
    let token = loading(text)
    do {
      let result = try await operation()
      token.dismiss()
      return result
    } catch {
      token.dismiss()
      _ = failure(error.localizedDescription)
      throw error
    }
  }

  public static func action(_ text: String, title: String) async -> Bool {
    await withCheckedContinuation { continuation in
      var tapped = false
      let token = action(text, title: title) { tapped = true }
      Task {
        await token.waitUntilDismissed()
        continuation.resume(returning: tapped)
      }
    }
  }
}
