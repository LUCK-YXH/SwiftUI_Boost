import SwiftUI

/// 弹窗宿主视图。渲染三种样式，1:1 对齐 Buzzme 弹窗设计稿：
/// - `.alert`：居中白卡，标题 + 说明 + 横排胶囊按钮，弹性缩放入场。
/// - `.actionSheet`：底部卡（grabber + 行 + 分隔线）+ 独立 Cancel 卡，底部滑入。
/// - `.hero`：居中白卡，图标徽章 + 标题 + 说明 + 主按钮(填充) + 次按钮(纯文字)。
/// - `.custom`：居中白卡包裹自定义内容。
public struct OverlayHost: View {
  @ObservedObject private var coordinator: OverlayCoordinator
  private let theme: OverlayTheme
  @State private var lastStyle: OverlayStyle = .alert
  /// 内部镜像的当前请求：仅通过 `withAnimation` 一次性事务更新，
  /// 避免用持久隐式动画（`.animation(_, value:)`）意外把卡片二次布局测量也一并动画，
  /// 从而消除弹窗「显示后高度再变化」的抖动。
  @State private var current: OverlayRequest?

  public init(coordinator: OverlayCoordinator, theme: OverlayTheme = .default) {
    self.coordinator = coordinator
    self.theme = theme
  }

  public var body: some View {
    GeometryReader { proxy in
      ZStack {
        if let request = current {
          dimColor(for: request)
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture {
              guard request.dismissOnBackgroundTap else { return }
              dismiss(request, reason: .background)
            }
            .transition(.opacity)

          OverlayCard(request: request, theme: theme) { reason in
            dismiss(request, reason: reason)
          }
          .padding(.top, request.style == .actionSheet ? 0 : proxy.safeAreaInsets.top)
          .padding(.bottom, request.style == .actionSheet ? proxy.safeAreaInsets.bottom : 0)
          .transition(transition(for: request))
          .zIndex(1)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .ignoresSafeArea()
    .allowsHitTesting(current != nil)
    .onAppear { sync(animated: false) }
    .onChange(of: coordinator.request?.id) { _ in sync() }
  }

  /// 将外部 `coordinator.request` 同步到内部 `current`，并把这次变化包进一次性动画事务。
  private func sync(animated: Bool = true) {
    let new = coordinator.request
    guard new?.id != current?.id else { return }
    let style = new?.style ?? current?.style ?? lastStyle
    if let style = new?.style { lastStyle = style }
    if animated {
      withAnimation(animation(for: style)) { current = new }
    } else {
      current = new
    }
  }

  private func dismiss(_ request: OverlayRequest, reason: OverlayDismissReason) {
    // 仅改动外部状态；由 `onChange` 统一用 `withAnimation` 播放离场，避免双重动画。
    coordinator.dismiss(id: request.id, reason: reason)
  }

  private func dimColor(for request: OverlayRequest) -> Color {
    switch request.style {
    case .actionSheet: return Color.black.opacity(theme.sheet.dimOpacity)
    case .hero: return theme.hero.dimColor.opacity(theme.hero.dimOpacity)
    case .alert, .custom: return Color.black.opacity(theme.alert.dimOpacity)
    }
  }

  private func animation(for style: OverlayStyle) -> Animation {
    switch style {
    // 底部面板：平顺贴合的滑入，几乎不回弹。
    case .actionSheet: return .spring(response: 0.42, dampingFraction: 0.88)
    // 居中卡片：轻微过冲的「弹跳」入场，更亲和。
    case .alert, .hero, .custom: return .spring(response: 0.4, dampingFraction: 0.68)
    }
  }

  private func transition(for request: OverlayRequest) -> AnyTransition {
    if let transition = request.transition {
      switch transition {
      case .fade: return .opacity
      case .scale: return .scale(scale: 0.88, anchor: .center).combined(with: .opacity)
      case .slide, .slideFromBottom: return .move(edge: .bottom).combined(with: .opacity)
      case .none: return .identity
      case .custom(let value): return value
      }
    }

    switch request.style {
    case .actionSheet: return .move(edge: .bottom).combined(with: .opacity)
    // 从稍小并略微下移处弹起，配合过冲弹簧得到柔和的 pop-in。
    case .alert, .hero, .custom:
      return .scale(scale: 0.88, anchor: .center)
        .combined(with: .opacity)
        .combined(with: .offset(y: 12))
    }
  }
}

// MARK: - Card container

private struct OverlayCard: View {
  let request: OverlayRequest
  let theme: OverlayTheme
  let dismiss: (OverlayDismissReason) -> Void
  @GestureState private var dragOffset: CGFloat = 0

  var body: some View {
    Group {
      if let mascot = request.mascot {
        ZStack(alignment: stackAlignment(mascot.anchor)) {
          card(topInset: mascot.restingHeight)
          MascotView(mascot: mascot)
            .offset(y: -mascot.overhang)
            .padding(.horizontal, mascotEdgeInset(mascot))
            .allowsHitTesting(false)
        }
      } else {
        card(topInset: 0)
      }
    }
    .offset(y: dragOffset)
    .gesture(swipeGesture)
  }

  @ViewBuilder private func card(topInset: CGFloat) -> some View {
    switch request.style {
    case .actionSheet:
      OverlayActionSheet(request: request, theme: theme.sheet, topInset: topInset, dismiss: dismiss)
    case .hero:
      OverlayHeroCard(request: request, theme: theme.hero, topInset: topInset, dismiss: dismiss)
    case .alert, .custom:
      OverlayAlertCard(request: request, theme: theme.alert, topInset: topInset, dismiss: dismiss)
    }
  }

  private func stackAlignment(_ anchor: OverlayMascot.Anchor) -> Alignment {
    switch anchor {
    case .leading: return .topLeading
    case .center: return .top
    case .trailing: return .topTrailing
    }
  }

  private func mascotEdgeInset(_ mascot: OverlayMascot) -> CGFloat {
    mascot.anchor == .center ? 0 : mascot.horizontalInset
  }

  private var swipeGesture: some Gesture {
    DragGesture()
      .updating($dragOffset) { value, state, _ in
        guard request.allowsSwipeToDismiss else { return }
        state = max(0, value.translation.height)
      }
      .onEnded { value in
        guard request.allowsSwipeToDismiss, value.translation.height > 60 else { return }
        dismiss(.swipe)
      }
  }
}

// MARK: - Alert（居中）

private struct OverlayAlertCard: View {
  let request: OverlayRequest
  let theme: OverlayTheme.Alert
  var topInset: CGFloat = 0
  let dismiss: (OverlayDismissReason) -> Void

  var body: some View {
    VStack(spacing: 0) {
      if !request.title.isEmpty {
        Text(request.title)
          .font(theme.titleFont)
          .foregroundColor(theme.titleColor)
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)
      }

      if let subtitle = request.subtitle, !subtitle.isEmpty {
        Text(subtitle)
          .font(theme.messageFont)
          .foregroundColor(theme.messageColor)
          .lineSpacing(theme.messageLineSpacing)
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)
          .padding(.top, request.title.isEmpty ? 0 : 8)
      }

      if let custom = request.customContent {
        custom.padding(.top, hasHeaderText ? 16 : 0)
      }

      OverlayButtonRow(actions: request.actions, layout: request.buttonLayout, theme: theme) { action in
        perform(action)
      }
      .padding(.top, hasHeaderText || request.customContent != nil ? 20 : 0)
    }
    .padding(.horizontal, 20)
    .padding(.top, 22 + topInset)
    .padding(.bottom, 20)
    .frame(width: theme.width)
    .background(theme.cardColor)
    .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
    .overlay(closeButton, alignment: .topTrailing)
    .shadow(color: theme.shadowColor, radius: theme.shadowRadius, x: 0, y: theme.shadowY)
  }

  private var hasHeaderText: Bool {
    !request.title.isEmpty || !(request.subtitle ?? "").isEmpty
  }

  @ViewBuilder private var closeButton: some View {
    if request.showsCloseButton {
      Button {
        dismiss(.closeButton)
      } label: {
        Image(systemName: "xmark")
          .font(.system(size: 12, weight: .bold))
          .foregroundColor(theme.titleColor.opacity(0.6))
          .padding(7)
          .background(Color.black.opacity(0.05), in: Circle())
      }
      .buttonStyle(.plain)
      .padding(12)
      .accessibilityLabel("Close")
    }
  }

  private func perform(_ action: OverlayAction) {
    action.action?()
    if request.dismissOnAction && action.dismissesOverlay {
      dismiss(.action)
    }
  }
}

/// Alert 胶囊按钮排布：cancel 置最左；动作 ≤2 横排等宽，否则纵排。
private struct OverlayButtonRow: View {
  let actions: [OverlayAction]
  let layout: OverlayButtonLayout
  let theme: OverlayTheme.Alert
  let perform: (OverlayAction) -> Void

  var body: some View {
    let ordered = actions.filter { $0.style == .cancel } + actions.filter { $0.style != .cancel }
    if !ordered.isEmpty {
      if isHorizontal(ordered) {
        HStack(spacing: 10) {
          ForEach(ordered) { button($0) }
        }
      } else {
        VStack(spacing: 10) {
          ForEach(ordered) { button($0) }
        }
      }
    }
  }

  private func isHorizontal(_ actions: [OverlayAction]) -> Bool {
    switch layout {
    case .automatic: return actions.count <= 2
    case .horizontal: return true
    case .vertical: return false
    }
  }

  private func button(_ action: OverlayAction) -> some View {
    Button {
      perform(action)
    } label: {
      Text(action.title)
        .font(theme.buttonFont)
        .foregroundColor(foreground(for: action.style))
        .frame(maxWidth: .infinity)
        .frame(height: theme.buttonHeight)
        .background(background(for: action.style))
        .clipShape(RoundedRectangle(cornerRadius: theme.buttonCornerRadius, style: .continuous))
    }
    .buttonStyle(OverlayPressStyle())
  }

  private func foreground(for style: OverlayActionStyle) -> Color {
    switch style {
    case .cancel: return theme.cancelTextColor
    case .destructive: return theme.destructiveTextColor
    case .primary, .secondary, .plain: return theme.defaultTextColor
    }
  }

  private func background(for style: OverlayActionStyle) -> Color {
    switch style {
    case .cancel: return theme.cancelColor
    case .destructive: return theme.destructiveColor
    case .primary, .secondary, .plain: return theme.defaultColor
    }
  }
}

// MARK: - Action sheet（底部）

private struct OverlayActionSheet: View {
  let request: OverlayRequest
  let theme: OverlayTheme.Sheet
  var topInset: CGFloat = 0
  let dismiss: (OverlayDismissReason) -> Void

  private var rows: [OverlayAction] { request.actions.filter { $0.style != .cancel } }
  private var cancel: OverlayAction? { request.actions.first { $0.style == .cancel } }

  var body: some View {
    VStack(spacing: theme.cardSpacing) {
      mainCard
      if let cancel {
        Button {
          perform(cancel)
        } label: {
          Text(cancel.title)
            .font(theme.cancelFont)
            .foregroundColor(theme.cancelTextColor)
            .frame(maxWidth: .infinity)
            .frame(height: theme.cancelHeight)
            .background(theme.cardColor)
            .clipShape(RoundedRectangle(cornerRadius: theme.cancelCornerRadius, style: .continuous))
            .shadow(color: theme.shadowColor, radius: theme.shadowRadius, x: 0, y: theme.shadowY)
        }
        .buttonStyle(OverlayPressStyle())
      }
    }
    .padding(.horizontal, theme.horizontalInset)
    .padding(.bottom, theme.bottomInset)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
  }

  private var mainCard: some View {
    VStack(spacing: 0) {
      RoundedRectangle(cornerRadius: theme.grabberSize.height / 2, style: .continuous)
        .fill(theme.grabberColor)
        .frame(width: theme.grabberSize.width, height: theme.grabberSize.height)
        .padding(.top, 10 + topInset)

      if hasHeader {
        header.padding(.top, 14).padding(.horizontal, theme.rowInset)
      }

      if let custom = request.customContent {
        custom.padding(.top, 14).padding(.horizontal, theme.rowInset)
      }

      VStack(spacing: 0) {
        ForEach(Array(rows.enumerated()), id: \.element.id) { index, action in
          if index > 0 {
            theme.separatorColor
              .frame(height: 1)
              .padding(.leading, theme.rowInset)
          }
          OverlaySheetRow(action: action, theme: theme) {
            perform(action)
          }
        }
      }
      .padding(.top, 14)
      .padding(.bottom, 8)
    }
    .background(theme.cardColor)
    .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
    .shadow(color: theme.shadowColor, radius: theme.shadowRadius, x: 0, y: theme.shadowY)
  }

  private var hasHeader: Bool {
    !request.title.isEmpty || !(request.subtitle ?? "").isEmpty
  }

  private var header: some View {
    VStack(spacing: 4) {
      if !request.title.isEmpty {
        Text(request.title)
          .font(theme.headerTitleFont)
          .foregroundColor(theme.headerColor)
          .multilineTextAlignment(.center)
      }
      if let message = request.subtitle, !message.isEmpty {
        Text(message)
          .font(theme.headerMessageFont)
          .foregroundColor(theme.headerColor)
          .multilineTextAlignment(.center)
      }
    }
    .frame(maxWidth: .infinity)
  }

  private func perform(_ action: OverlayAction) {
    action.action?()
    if request.dismissOnAction && action.dismissesOverlay {
      dismiss(.action)
    }
  }
}

/// Action sheet 单行：标题 +（可选）副标题，destructive 标题红色；按下高亮。
private struct OverlaySheetRow: View {
  let action: OverlayAction
  let theme: OverlayTheme.Sheet
  let tap: () -> Void

  var body: some View {
    Button(action: tap) {
      VStack(alignment: .leading, spacing: 3) {
        Text(action.title)
          .font(theme.titleFont)
          .foregroundColor(action.style == .destructive ? theme.destructiveColor : theme.titleColor)
        if let subtitle = action.subtitle, !subtitle.isEmpty {
          Text(subtitle)
            .font(theme.subtitleFont)
            .foregroundColor(theme.subtitleColor)
        }
      }
      .multilineTextAlignment(.leading)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.vertical, theme.rowVerticalPadding)
      .padding(.horizontal, theme.rowInset)
      .contentShape(Rectangle())
    }
    .buttonStyle(OverlayHighlightStyle(color: theme.highlightColor))
  }
}

// MARK: - Hero（居中，图标徽章）

private struct OverlayHeroCard: View {
  let request: OverlayRequest
  let theme: OverlayTheme.Hero
  var topInset: CGFloat = 0
  let dismiss: (OverlayDismissReason) -> Void

  private var primary: OverlayAction? { request.actions.first { $0.style != .cancel } }
  private var secondary: OverlayAction? { request.actions.first { $0.style == .cancel } }

  var body: some View {
    VStack(spacing: 0) {
      badge.padding(.bottom, 16)

      if !request.title.isEmpty {
        Text(request.title)
          .font(theme.titleFont)
          .foregroundColor(theme.titleColor)
          .multilineTextAlignment(.center)
          .padding(.bottom, 6)
      }

      if let subtitle = request.subtitle, !subtitle.isEmpty {
        Text(subtitle)
          .font(theme.messageFont)
          .foregroundColor(theme.messageColor)
          .lineSpacing(theme.messageLineSpacing)
          .multilineTextAlignment(.center)
          .padding(.bottom, 20)
      }

      if let primary {
        Button {
          perform(primary)
        } label: {
          Text(primary.title)
            .font(theme.primaryFont)
            .foregroundColor(theme.primaryTextColor)
            .frame(maxWidth: .infinity)
            .frame(height: theme.primaryHeight)
            .background(theme.primaryColor)
            .clipShape(RoundedRectangle(cornerRadius: theme.primaryCornerRadius, style: .continuous))
        }
        .buttonStyle(OverlayPressStyle())

        if let secondary {
          Button {
            perform(secondary)
          } label: {
            Text(secondary.title)
              .font(theme.secondaryFont)
              .foregroundColor(theme.secondaryColor)
              .frame(maxWidth: .infinity)
              .frame(height: theme.secondaryHeight)
          }
          .buttonStyle(OverlayPressStyle())
          .padding(.top, 12)
        }
      }
    }
    .padding(.horizontal, 22)
    .padding(.top, 26 + topInset)
    .padding(.bottom, 22)
    .frame(width: theme.width)
    .background(theme.cardColor)
    .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
    .shadow(color: theme.shadowColor, radius: theme.shadowRadius, x: 0, y: theme.shadowY)
  }

  private var badge: some View {
    ZStack {
      RoundedRectangle(cornerRadius: theme.iconCornerRadius, style: .continuous)
        .fill(request.iconBackground ?? theme.iconBackground)
        .frame(width: theme.iconSize, height: theme.iconSize)
      glyph
        .frame(width: theme.iconGlyphSize, height: theme.iconGlyphSize)
    }
  }

  @ViewBuilder private var glyph: some View {
    switch request.icon ?? .system("sparkles") {
    case .system(let name):
      Image(systemName: name).resizable().scaledToFit()
        .foregroundColor(theme.iconTint)
    case .image(let image):
      image.resizable().scaledToFit().foregroundColor(theme.iconTint)
    case .custom(let view):
      view
    }
  }

  private func perform(_ action: OverlayAction) {
    action.action?()
    if request.dismissOnAction && action.dismissesOverlay {
      dismiss(.action)
    }
  }
}

// MARK: - Mascot（趴在弹窗顶沿的动画形象）

/// 入场时从底部「弹起 / 探头」并轻轻扶正，随后持续做柔和的上下呼吸。
private struct MascotView: View {
  let mascot: OverlayMascot
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var landed = false
  @State private var bob: CGFloat = 0

  var body: some View {
    glyph
      .frame(width: mascot.size.width, height: mascot.size.height)
      .scaleEffect(landed ? 1 : 0.4, anchor: .bottom)
      .rotationEffect(.degrees(landed ? 0 : -8), anchor: .bottom)
      .opacity(landed ? 1 : 0)
      .offset(y: bob)
      .onAppear(perform: start)
  }

  @ViewBuilder private var glyph: some View {
    switch mascot.content {
    case .system(let name):
      Image(systemName: name).resizable().scaledToFit()
    case .image(let image):
      image.resizable().scaledToFit()
    case .view(let view):
      view
    }
  }

  private func start() {
    guard mascot.animated, !reduceMotion else {
      landed = true
      return
    }
    withAnimation(.spring(response: 0.5, dampingFraction: 0.56).delay(0.06)) {
      landed = true
    }
    withAnimation(.easeInOut(duration: 1.9).repeatForever(autoreverses: true).delay(0.65)) {
      bob = -5
    }
  }
}

// MARK: - Button styles

/// 填充胶囊按钮按下时轻微变淡。
private struct OverlayPressStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label.opacity(configuration.isPressed ? 0.72 : 1)
  }
}

/// Action sheet 行按下时整行高亮。
private struct OverlayHighlightStyle: ButtonStyle {
  let color: Color
  func makeBody(configuration: Configuration) -> some View {
    configuration.label.background(configuration.isPressed ? color : Color.clear)
  }
}

// MARK: - View helpers

extension View {
  public func boostOverlay(_ coordinator: OverlayCoordinator, theme: OverlayTheme = .default) -> some View {
    overlay(OverlayHost(coordinator: coordinator, theme: theme))
  }
}
