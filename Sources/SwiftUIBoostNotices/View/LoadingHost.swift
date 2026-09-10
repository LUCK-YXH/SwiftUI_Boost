import SwiftUI

public struct LoadingHost: View {
  @ObservedObject private var coordinator: LoadingCoordinator
  public init(coordinator: LoadingCoordinator) { self.coordinator = coordinator }
  public var body: some View {
    if let configuration = coordinator.configuration {
      ZStack {
        configuration.background.ignoresSafeArea()
        VStack(spacing: 12) {
          ProgressView().progressViewStyle(.circular).tint(configuration.tint).frame(
            width: configuration.size.width, height: configuration.size.height)
          if let text = configuration.text {
            Text(text).font(.footnote.weight(.medium)).foregroundStyle(configuration.textColor)
          }
        }
      }.allowsHitTesting(configuration.blocksTouches).transition(.opacity)
    }
  }
}

extension View {
  public func loadingHost(_ coordinator: LoadingCoordinator) -> some View {
    overlay(LoadingHost(coordinator: coordinator))
  }
}
