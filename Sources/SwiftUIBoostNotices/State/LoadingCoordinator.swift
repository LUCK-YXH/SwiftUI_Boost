import SwiftUI

@MainActor public final class LoadingHandle {
  fileprivate let id = UUID()
  private weak var coordinator: LoadingCoordinator?
  fileprivate init(coordinator: LoadingCoordinator) { self.coordinator = coordinator }
  public func dismiss() { coordinator?.dismiss(id: id) }
}

@MainActor public final class LoadingCoordinator: ObservableObject {
  public static let shared = LoadingCoordinator()
  @Published public private(set) var configuration: LoadingConfiguration?
  private var activeID: UUID?
  public init() {}
  @discardableResult public func show(_ configuration: LoadingConfiguration = .init())
    -> LoadingHandle
  {
    dismiss()
    let handle = LoadingHandle(coordinator: self)
    activeID = handle.id
    self.configuration = configuration
    return handle
  }
  public func dismiss(id: UUID) {
    guard activeID == id else { return }
    activeID = nil
    configuration = nil
  }
  public func dismiss() {
    activeID = nil
    configuration = nil
  }
}
