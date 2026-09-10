import SwiftUI

private struct SkeletonPhaseKey: EnvironmentKey {
  static let defaultValue: CGFloat? = nil
}

private extension EnvironmentValues {
  var skeletonPhase: CGFloat? {
    get { self[SkeletonPhaseKey.self] }
    set { self[SkeletonPhaseKey.self] = newValue }
  }
}

/// A shared animation clock for a group of skeleton views.
///
/// Place a card, feed row, or detail page inside this container to make all
/// nested skeleton components shimmer in the same horizontal rhythm.
public struct SkeletonShimmerContainer<Content: View>: View {
  private let configuration: SkeletonConfiguration
  private let content: Content

  public init(
    configuration: SkeletonConfiguration = .buzzme,
    @ViewBuilder content: () -> Content
  ) {
    self.configuration = configuration
    self.content = content()
  }

  public var body: some View {
    TimelineView(.animation) { timeline in
      content
        .environment(
          \.skeletonPhase,
          configuration.shimmerPhase(at: timeline.date.timeIntervalSinceReferenceDate)
        )
    }
  }
}

public struct SkeletonModifier: ViewModifier {
  let configuration: SkeletonConfiguration
  @Environment(\.skeletonPhase) private var sharedPhase

  public func body(content: Content) -> some View {
    Group {
      if let sharedPhase {
        skeletonContent(content, phase: sharedPhase)
      } else {
        TimelineView(.animation) { timeline in
          skeletonContent(
            content,
            phase: configuration.shimmerPhase(at: timeline.date.timeIntervalSinceReferenceDate)
          )
        }
      }
    }
  }

  @ViewBuilder
  private func skeletonContent(_ content: Content, phase: CGFloat) -> some View {
    content
      // Hide the original content visually while preserving its measured layout.
      .hidden()
      .overlay {
        GeometryReader { proxy in
          let width = max(proxy.size.width, 1)
          let shimmerWidth = max(width * configuration.shimmerWidthRatio, 1)
          let placeholder = content.redacted(reason: .placeholder)

          ZStack(alignment: .leading) {
            configuration.base

            LinearGradient(
              colors: [.clear, configuration.highlight, .clear],
              startPoint: .leading,
              endPoint: .trailing
            )
            .frame(width: shimmerWidth)
            .offset(x: phase * (width + shimmerWidth))
          }
          .mask(placeholder)
        }
        .clipped()
      }
  }
}

extension View {
  /// Applies a Buzzme-style placeholder redaction and animated shimmer.
  public func skeleton(
    _ active: Bool = true,
    configuration: SkeletonConfiguration = .buzzme
  ) -> some View {
    modifier(SkeletonConditionalModifier(active: active, configuration: configuration))
  }
}

private struct SkeletonConditionalModifier: ViewModifier {
  let active: Bool
  let configuration: SkeletonConfiguration

  func body(content: Content) -> some View {
    if active {
      content.modifier(SkeletonModifier(configuration: configuration))
    } else {
      content
    }
  }
}

/// A rounded placeholder block for composing custom skeleton layouts.
public struct SkeletonBlock: View {
  let width: CGFloat?
  let height: CGFloat
  let radius: CGFloat
  let configuration: SkeletonConfiguration

  public init(
    width: CGFloat? = nil,
    height: CGFloat = 16,
    cornerRadius: CGFloat = 8,
    configuration: SkeletonConfiguration = .buzzme
  ) {
    self.width = width
    self.height = height
    radius = cornerRadius
    self.configuration = configuration
  }

  public var body: some View {
    RoundedRectangle(cornerRadius: radius, style: .continuous)
      .fill(configuration.base)
      .frame(width: width, height: height)
      .skeleton(configuration: configuration)
  }
}

/// A circular placeholder, useful for avatars and icon slots.
public struct SkeletonCircle: View {
  let diameter: CGFloat
  let configuration: SkeletonConfiguration

  public init(diameter: CGFloat = 44, configuration: SkeletonConfiguration = .buzzme) {
    self.diameter = diameter
    self.configuration = configuration
  }

  public var body: some View {
    Circle()
      .fill(configuration.base)
      .frame(width: diameter, height: diameter)
      .skeleton(configuration: configuration)
  }
}

/// A pill-shaped placeholder for tags, metadata, and action controls.
public struct SkeletonCapsule: View {
  let width: CGFloat
  let height: CGFloat
  let configuration: SkeletonConfiguration

  public init(width: CGFloat = 72, height: CGFloat = 28, configuration: SkeletonConfiguration = .buzzme) {
    self.width = width
    self.height = height
    self.configuration = configuration
  }

  public var body: some View {
    Capsule()
      .fill(configuration.base)
      .frame(width: width, height: height)
      .skeleton(configuration: configuration)
  }
}
