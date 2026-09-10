import Foundation

public struct NoticeQueueItem: Equatable {
  public let id: UUID
  public let policy: NoticeQueuePolicy
  public init(id: UUID, policy: NoticeQueuePolicy) {
    self.id = id
    self.policy = policy
  }
}

public enum NoticeQueueDecision: Equatable {
  case presentNow
  case wait
  case replace([UUID])
  case stack
}

public final class NoticeQueue {
  public private(set) var activeIDs: [UUID] = []
  private var waiting: [NoticeQueueItem] = []
  public init() {}

  public func enqueue(_ item: NoticeQueueItem) -> NoticeQueueDecision {
    switch item.policy {
    case .queue:
      guard activeIDs.isEmpty else {
        waiting.append(item)
        return .wait
      }
      activeIDs = [item.id]
      return .presentNow
    case .replace:
      let replaced = activeIDs
      activeIDs = [item.id]
      waiting.removeAll()
      return .replace(replaced)
    case .stack:
      activeIDs.append(item.id)
      return .stack
    }
  }

  public func finish(_ id: UUID) -> UUID? {
    activeIDs.removeAll { $0 == id }
    guard activeIDs.isEmpty, let next = waiting.first else { return nil }
    waiting.removeFirst()
    activeIDs = [next.id]
    return next.id
  }

  public func remove(_ id: UUID) {
    activeIDs.removeAll { $0 == id }
    waiting.removeAll { $0.id == id }
  }

  public func reset() {
    activeIDs.removeAll()
    waiting.removeAll()
  }
}
