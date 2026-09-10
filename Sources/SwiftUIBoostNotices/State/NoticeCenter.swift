import SwiftUI

@MainActor
public final class NoticeToken: ObservableObject {
  public let id: UUID
  private weak var center: NoticeCenter?
  fileprivate var onDismissHandler: (() -> Void)?

  fileprivate init(id: UUID, center: NoticeCenter) {
    self.id = id
    self.center = center
  }

  public func updateText(_ text: String) { center?.updateText(id: id, text: text) }
  public func update(_ progress: Double) { center?.updateProgress(id: id, value: progress) }
  public func updateProgress(_ progress: Double) { update(progress) }
  public func dismiss() { center?.dismiss(id: id) }

  public func finish(_ text: String) {
    update(1)
    updateText(text)
    Task {
      try? await Task.sleep(nanoseconds: 800_000_000)
      guard !Task.isCancelled else { return }
      dismiss()
    }
  }

  public func waitUntilDismissed() async {
    await withCheckedContinuation { continuation in
      let previous = onDismissHandler
      onDismissHandler = {
        previous?()
        continuation.resume()
      }
    }
  }
}

@MainActor
public final class NoticeCenter: ObservableObject {
  public static let shared = NoticeCenter()
  public var configuration: NoticeConfiguration
  @Published public private(set) var notices: [NoticeRequest] = []
  @Published private var progressValues: [UUID: Double] = [:]

  private let queue = NoticeQueue()
  private var queuedRequests: [UUID: NoticeRequest] = [:]
  private var expirationTasks: [UUID: Task<Void, Never>] = [:]
  private var tokens: [UUID: NoticeToken] = [:]

  public init(configuration: NoticeConfiguration = .init()) {
    self.configuration = configuration
  }

  @discardableResult
  public func show(_ text: String) -> NoticeToken {
    present(configuration.request(content: .text(text)))
  }

  @discardableResult
  public func success(_ text: String) -> NoticeToken {
    present(configuration.request(content: .icon(.success, text)))
  }

  @discardableResult
  public func failure(_ text: String) -> NoticeToken {
    present(configuration.request(content: .icon(.failure, text)))
  }

  @discardableResult
  public func warning(_ text: String) -> NoticeToken {
    present(configuration.request(content: .icon(.warning, text)))
  }

  @discardableResult
  public func information(_ text: String) -> NoticeToken {
    present(configuration.request(content: .icon(.information, text)))
  }

  @discardableResult
  public func loading(_ text: String? = nil) -> NoticeToken {
    var options = NoticePartialOptions()
    options.lifetime = .persistent
    return present(configuration.request(content: .loading(text), options: options))
  }

  @discardableResult
  public func progress(_ text: String? = nil) -> NoticeToken {
    var options = NoticePartialOptions()
    options.lifetime = .persistent
    return present(configuration.request(content: .progress(text), options: options))
  }

  @discardableResult
  public func action(
    _ text: String,
    title: String,
    handler: @escaping () -> Void
  ) -> NoticeToken {
    var options = NoticePartialOptions()
    options.lifetime = .seconds(4)
    return present(
      configuration.request(
        content: .action(text, title: title),
        options: options,
        action: handler
      )
    )
  }

  @discardableResult
  public func present(_ request: NoticeRequest) -> NoticeToken {
    let token = NoticeToken(id: request.id, center: self)
    tokens[request.id] = token
    let decision = queue.enqueue(.init(id: request.id, policy: request.options.queue))

    switch decision {
    case .presentNow, .stack:
      notices.append(request)
      scheduleExpiration(for: request)
    case .wait:
      queuedRequests[request.id] = request
    case .replace(let ids):
      ids.forEach { removeActive(id: $0, notify: true) }
      notices.append(request)
      scheduleExpiration(for: request)
    }

    return token
  }

  public func dismiss(id: UUID) {
    guard notices.contains(where: { $0.id == id }) else {
      queuedRequests[id] = nil
      queue.remove(id)
      tokens[id]?.onDismissHandler?()
      tokens[id] = nil
      return
    }
    let nextID = queue.finish(id)
    removeActive(id: id, notify: true)
    presentNextIfNeeded(id: nextID)
  }

  public func dismissCurrent() {
    guard let id = notices.last?.id else { return }
    dismiss(id: id)
  }

  public func dismissAll() {
    let ids = notices.map(\.id) + Array(queuedRequests.keys)
    ids.forEach { expirationTasks[$0]?.cancel() }
    notices.forEach { $0.onDismiss?() }
    ids.forEach { tokens[$0]?.onDismissHandler?() }
    expirationTasks.removeAll()
    queuedRequests.removeAll()
    tokens.removeAll()
    notices.removeAll()
    progressValues.removeAll()
    queue.reset()
  }

  private func removeActive(id: UUID, notify: Bool) {
    expirationTasks[id]?.cancel()
    expirationTasks[id] = nil
    queuedRequests[id] = nil
    guard let index = notices.firstIndex(where: { $0.id == id }) else { return }
    let request = notices.remove(at: index)
    if notify {
      request.onDismiss?()
      tokens[id]?.onDismissHandler?()
    }
    tokens[id] = nil
    progressValues[id] = nil
    queue.remove(id)
  }

  public func updateText(id: UUID, text: String) {
    guard let index = notices.firstIndex(where: { $0.id == id }) else { return }

    switch notices[index].content {
    case .text:
      notices[index].content = .text(text)
    case .icon(let icon, _):
      notices[index].content = .icon(icon, text)
    case .loading:
      notices[index].content = .loading(text)
    case .progress:
      notices[index].content = .progress(text)
    case .action(_, let title):
      notices[index].content = .action(text, title: title)
    case .custom:
      break
    }
  }

  public func updateProgress(id: UUID, value: Double) {
    progressValues[id] = min(max(value, 0), 1)
  }

  public func progressValue(for id: UUID) -> Double {
    progressValues[id] ?? 0
  }

  private func presentNextIfNeeded(id nextID: UUID?) {
    guard notices.isEmpty,
      let nextID,
      let next = queuedRequests.removeValue(forKey: nextID)
    else { return }
    notices = [next]
    scheduleExpiration(for: next)
  }

  private func scheduleExpiration(for request: NoticeRequest) {
    let lifetime = automaticLifetime(for: request)
    guard case .seconds(let seconds) = lifetime else { return }

    expirationTasks[request.id] = Task { [weak self] in
      try? await Task.sleep(nanoseconds: UInt64(max(seconds, 0) * 1_000_000_000))
      guard !Task.isCancelled else { return }
      self?.dismiss(id: request.id)
    }
  }

  private func automaticLifetime(for request: NoticeRequest) -> NoticeLifetime {
    switch request.options.lifetime {
    case .automatic:
      return .seconds(min(max(1.5 + Double(request.title.count) * 0.06, 1.5), 6))
    default:
      return request.options.lifetime
    }
  }
}

extension NoticeRequest {
  fileprivate var title: String {
    switch content {
    case .text(let text), .icon(_, let text): return text
    case .loading(let text), .progress(let text): return text ?? ""
    case .action(let text, _): return text
    case .custom: return ""
    }
  }
}
