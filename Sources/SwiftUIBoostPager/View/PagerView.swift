import SwiftUI

public struct PagerView<Data: RandomAccessCollection, Content: View>: View
where Data.Element: Identifiable {
  private let data: Data
  private let configuration: PagerConfiguration
  private let content: (Data.Element) -> Content
  @State private var index: Int
  @GestureState private var drag: CGSize = .zero
  public init(
    _ data: Data, configuration: PagerConfiguration = .init(),
    @ViewBuilder content: @escaping (Data.Element) -> Content
  ) {
    self.data = data
    self.configuration = configuration
    self.content = content
    let initial = min(max(configuration.initialIndex, 0), max(data.count - 1, 0))
    _index = State(initialValue: initial)
  }
  public var body: some View {
    GeometryReader { proxy in
      Group { if configuration.axis == .horizontal { horizontal(proxy) } else { vertical(proxy) } }
    }.clipped().contentShape(Rectangle()).gesture(dragGesture)
  }
  private func horizontal(_ proxy: GeometryProxy) -> some View {
    HStack(spacing: configuration.spacing) {
      ForEach(Array(data.enumerated()), id: \.element.id) { offset, item in
        content(item).frame(
          width: max(0, proxy.size.width - configuration.peek), height: proxy.size.height
        ).id(offset)
      }
    }.padding(.horizontal, configuration.contentInset.leading).offset(
      x: -CGFloat(index) * (proxy.size.width - configuration.peek + configuration.spacing)
        + drag.width
    ).animation(.easeOut(duration: 0.22), value: index)
  }
  private func vertical(_ proxy: GeometryProxy) -> some View {
    VStack(spacing: configuration.spacing) {
      ForEach(Array(data.enumerated()), id: \.element.id) { offset, item in
        content(item).frame(
          width: proxy.size.width, height: max(0, proxy.size.height - configuration.peek)
        ).id(offset)
      }
    }.padding(.vertical, configuration.contentInset.top).offset(
      y: -CGFloat(index) * (proxy.size.height - configuration.peek + configuration.spacing)
        + drag.height
    ).animation(.easeOut(duration: 0.22), value: index)
  }
  private var dragGesture: some Gesture {
    DragGesture().updating($drag) { value, state, _ in state = value.translation }.onEnded {
      value in
      let distance =
        configuration.axis == .horizontal ? value.translation.width : value.translation.height
      var next = index
      if distance < -40 { next += 1 }
      if distance > 40 { next -= 1 }
      switch configuration.direction {
      case .free: break
      case .forwardOnly: if distance > 40 { next = index }
      case .backwardOnly: if distance < -40 { next = index }
      }
      index = min(max(next, 0), max(data.count - 1, 0))
    }
  }
}
