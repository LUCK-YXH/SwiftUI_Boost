import SwiftUI

public struct NoticeHost: View {
  @ObservedObject private var center: NoticeCenter
  private let additionalInsets: NoticeHostInsets

  public init(center: NoticeCenter) {
    self.init(center: center, additionalInsets: .init())
  }

  init(center: NoticeCenter, additionalInsets: NoticeHostInsets) {
    self.center = center
    self.additionalInsets = additionalInsets
  }

  public var body: some View {
    GeometryReader { proxy in
      ZStack {
        NoticePlacementStack(
          center: center,
          notices: notices(for: .top),
          alignment: .top,
          safeAreaInset: proxy.safeAreaInsets.top + additionalInsets.top
        )

        NoticePlacementStack(
          center: center,
          notices: notices(for: .center),
          alignment: .center,
          safeAreaInset: 0
        )

        NoticePlacementStack(
          center: center,
          notices: notices(for: .bottom),
          alignment: .bottom,
          safeAreaInset: proxy.safeAreaInsets.bottom + additionalInsets.bottom
        )
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .animation(.easeInOut(duration: 0.22), value: center.notices.map(\.id))
    }
  }

  private func notices(for placement: NoticePlacement) -> [NoticeRequest] {
    center.notices.filter { $0.options.placement == placement }
  }
}

private struct NoticePlacementStack: View {
  let center: NoticeCenter
  let notices: [NoticeRequest]
  let alignment: Alignment
  let safeAreaInset: CGFloat

  var body: some View {
    VStack(spacing: 8) {
      if alignment == .bottom {
        Spacer(minLength: 0)
      }

      ForEach(notices) { request in
        NoticeCard(
          request: request,
          progress: center.progressValue(for: request.id)
        ) {
          center.dismiss(id: request.id)
        }
        .frame(maxWidth: request.options.maxWidth)
        .background(
          GeometryReader { proxy in
            Color.clear.preference(
              key: NoticeHitRegionPreferenceKey.self,
              value: [proxy.frame(in: .global)]
            )
          }
        )
        .transition(transition(for: request.options.presentation))
      }

      if alignment != .bottom {
        Spacer(minLength: 0)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    .padding(.top, alignment == .top ? safeAreaInset + 16 : 0)
    .padding(.bottom, alignment == .bottom ? safeAreaInset + 16 : 0)
    .padding(.horizontal, 16)
  }

  private func transition(for presentation: NoticePresentation) -> AnyTransition {
    switch presentation {
    case .fade:
      return .opacity
    case .slide:
      return .move(edge: alignment == .bottom ? .bottom : .top).combined(with: .opacity)
    case .scale:
      return .scale.combined(with: .opacity)
    case .none:
      return .identity
    }
  }
}

struct NoticeHitRegionPreferenceKey: PreferenceKey {
  static var defaultValue: [CGRect] { [] }

  static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
    value.append(contentsOf: nextValue())
  }
}

extension View {
  public func noticeHost(_ center: NoticeCenter) -> some View {
    overlay(NoticeHost(center: center))
  }
}
