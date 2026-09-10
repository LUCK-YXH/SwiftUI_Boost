import SwiftUI

public struct NoticeHost: View {
  @ObservedObject private var center: NoticeCenter
  @ObservedObject private var bars = NoticeBarObserver.shared

  public init(center: NoticeCenter) {
    self.center = center
  }

  public var body: some View {
    GeometryReader { proxy in
      // 挂载位置不同，proxy.safeAreaInsets 的含义也不同（页面内已含导航栏，根视图外不含），
      // 因此一律换算成窗口坐标系再和栏位边界比较，避免重复计入。
      let frame = proxy.frame(in: .global)
      let metrics = bars.metrics

      ZStack {
        NoticePlacementStack(
          center: center,
          notices: notices(for: .top),
          alignment: .top,
          barInset: max(0, metrics.topBoundary - frame.minY)
        )

        NoticePlacementStack(
          center: center,
          notices: notices(for: .center),
          alignment: .center,
          barInset: 0
        )

        NoticePlacementStack(
          center: center,
          notices: notices(for: .bottom),
          alignment: .bottom,
          barInset: max(0, frame.maxY - metrics.bottomBoundary)
        )
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .animation(.easeInOut(duration: 0.22), value: center.notices.map(\.id))
      .onAppear { bars.refresh() }
      .onChange(of: center.notices.count) { _ in bars.refresh() }
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
  let barInset: CGFloat

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
    .padding(.top, alignment == .top ? barInset + 8 : 0)
    .padding(.bottom, alignment == .bottom ? barInset + 24 : 0)
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
