import SwiftUI

@MainActor public final class OverlayCoordinator: ObservableObject {
  @Published public var request: OverlayRequest?
  public init() {}

  public func present(_ request: OverlayRequest) {
    if let current = self.request {
      self.request = request
      current.onDismiss?(.replaced)
      return
    }
    self.request = request
  }

  public func dismiss(reason: OverlayDismissReason = .programmatic) {
    guard let id = request?.id else { return }
    dismiss(id: id, reason: reason)
  }

  public func dismiss(id: UUID, reason: OverlayDismissReason = .programmatic) {
    guard let current = request, current.id == id else { return }
    request = nil
    current.onDismiss?(reason)
  }
}
