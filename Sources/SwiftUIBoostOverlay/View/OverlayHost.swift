import SwiftUI

public struct OverlayHost: View {
  @ObservedObject private var coordinator: OverlayCoordinator

  public init(coordinator: OverlayCoordinator) {
    self.coordinator = coordinator
  }

  public var body: some View {
    GeometryReader { proxy in
      ZStack {
        if let request = coordinator.request {
          Color.black.opacity(request.style == .actionSheet ? 0.22 : 0.35)
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture {
              guard request.dismissOnBackgroundTap else { return }
              withAnimation(.easeInOut(duration: 0.22)) {
                coordinator.dismiss(id: request.id, reason: .background)
              }
            }

          OverlayCard(request: request) { reason in
            withAnimation(.easeInOut(duration: 0.22)) {
              coordinator.dismiss(id: request.id, reason: reason)
            }
          }
          .padding(.top, request.style == .actionSheet ? 0 : proxy.safeAreaInsets.top)
          .padding(.bottom, request.style == .actionSheet ? proxy.safeAreaInsets.bottom : 0)
          .transition(transition(for: request))
          .zIndex(1)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .animation(.easeInOut(duration: 0.22), value: coordinator.request?.id)
    }
    .ignoresSafeArea()
    .allowsHitTesting(coordinator.request != nil)
  }

  private func transition(for request: OverlayRequest) -> AnyTransition {
    if let transition = request.transition {
      switch transition {
      case .fade: return .opacity
      case .scale: return .scale.combined(with: .opacity)
      case .slide, .slideFromBottom: return .move(edge: .bottom).combined(with: .opacity)
      case .none: return .identity
      case .custom(let value): return value
      }
    }

    switch request.style {
    case .actionSheet: return .move(edge: .bottom).combined(with: .opacity)
    case .alert, .hero, .custom: return .scale.combined(with: .opacity)
    }
  }
}

private struct OverlayCard: View {
  let request: OverlayRequest
  let dismiss: (OverlayDismissReason) -> Void
  @GestureState private var dragOffset: CGSize = .zero

  var body: some View {
    Group {
      if let customContent = request.customContent {
        customContainer(customContent)
      } else if request.style == .actionSheet {
        actionSheet
      } else {
        alert
      }
    }
    .offset(y: dragOffset.height)
    .gesture(swipeGesture)
  }

  private var alert: some View {
    card {
      header
      if let subtitle = request.subtitle, !subtitle.isEmpty {
        Text(subtitle)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
      }
      actions
    }
  }

  private var actionSheet: some View {
    VStack(spacing: 10) {
      card {
        header
        if let subtitle = request.subtitle, !subtitle.isEmpty {
          Text(subtitle)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        actions
      }
      .padding(.horizontal, 12)

      if request.actions.contains(where: { $0.style == .cancel }) == false,
         request.showsCloseButton == false {
        EmptyView()
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
  }

  private func customContainer(_ content: AnyView) -> some View {
    card {
      header
      content
      actions
    }
  }

  private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    VStack(spacing: 16, content: content)
      .padding(22)
      .frame(maxWidth: request.style == .actionSheet ? .infinity : 360)
      .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
      .padding(.horizontal, request.style == .actionSheet ? 0 : 22)
      .padding(.bottom, request.style == .actionSheet ? 0 : 22)
  }

  @ViewBuilder private var header: some View {
    ZStack(alignment: .topTrailing) {
      VStack(spacing: 12) {
        if let icon = request.icon {
          OverlayIconView(icon: icon, style: request.style)
        } else if request.style == .hero {
          OverlayIconView(icon: .system("sparkles"), style: request.style)
        }

        if !request.title.isEmpty {
          Text(request.title)
            .font(.headline)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
        }
      }
      if request.showsCloseButton {
        Button {
          dismiss(.closeButton)
        } label: {
          Image(systemName: "xmark")
            .font(.caption.weight(.bold))
            .padding(7)
            .background(.quaternary, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close")
      }
    }
  }

  @ViewBuilder private var actions: some View {
    let visibleActions = request.actions.filter { $0.style != .cancel || request.style != .actionSheet }
    if !visibleActions.isEmpty {
      let layout = resolvedLayout(for: visibleActions)
      if layout == .horizontal {
        HStack(spacing: 10) {
          ForEach(visibleActions) { actionButton($0) }
        }
      } else {
        VStack(spacing: 10) {
          ForEach(visibleActions) { actionButton($0) }
        }
      }
    }

    if request.style == .actionSheet,
       let cancel = request.actions.first(where: { $0.style == .cancel }) {
      actionButton(cancel)
    }
  }

  private func actionButton(_ action: OverlayAction) -> some View {
    Button(role: action.role) {
      action.action?()
      if request.dismissOnAction && action.dismissesOverlay {
        dismiss(.action)
      }
    } label: {
      VStack(spacing: 3) {
        Text(action.title)
          .font(action.style == .primary || action.style == .destructive ? .body.weight(.semibold) : .body)
        if let subtitle = action.subtitle {
          Text(subtitle)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      .frame(maxWidth: .infinity, minHeight: request.style == .actionSheet ? 48 : 42)
    }
    .buttonStyle(OverlayButtonStyle(style: action.style))
  }

  private func resolvedLayout(for actions: [OverlayAction]) -> OverlayButtonLayout {
    switch request.buttonLayout {
    case .automatic: return actions.count == 2 && request.style != .actionSheet ? .horizontal : .vertical
    case .vertical: return .vertical
    case .horizontal: return .horizontal
    }
  }

  private var swipeGesture: some Gesture {
    DragGesture()
      .updating($dragOffset) { value, state, _ in
        guard request.allowsSwipeToDismiss else { return }
        state = CGSize(width: 0, height: max(0, value.translation.height))
      }
      .onEnded { value in
        guard request.allowsSwipeToDismiss, value.translation.height > 50 else { return }
        dismiss(.swipe)
      }
  }
}

private struct OverlayIconView: View {
  let icon: OverlayIcon
  let style: OverlayStyle

  var body: some View {
    Group {
      switch icon {
      case .system(let name): Image(systemName: name)
      case .image(let image): image
      case .custom(let view): view
      }
    }
    .font(.system(size: style == .hero ? 34 : 24, weight: .semibold))
    .foregroundStyle(.tint)
    .frame(width: style == .hero ? 68 : 48, height: style == .hero ? 68 : 48)
    .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: style == .hero ? 20 : 14, style: .continuous))
  }
}

private struct OverlayButtonStyle: ButtonStyle {
  let style: OverlayActionStyle

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundStyle(foreground)
      .background(background, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
      .opacity(configuration.isPressed ? 0.72 : 1)
  }

  private var foreground: Color {
    switch style {
    case .primary: return .white
    case .destructive: return .white
    case .secondary, .cancel, .plain: return .primary
    }
  }

  private var background: Color {
    switch style {
    case .primary: return .accentColor
    case .destructive: return .red
    case .secondary: return Color.secondary.opacity(0.16)
    case .cancel, .plain: return .clear
    }
  }
}

extension View {
  public func boostOverlay(_ coordinator: OverlayCoordinator) -> some View {
    overlay(OverlayHost(coordinator: coordinator))
  }
}
