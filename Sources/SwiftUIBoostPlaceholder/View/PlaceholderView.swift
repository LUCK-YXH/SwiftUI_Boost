import SwiftUI

public struct PlaceholderView: View {
  private let configuration: PlaceholderConfiguration
  private let theme: PlaceholderTheme

  public init(
    state: PlaceholderState,
    actions: [PlaceholderAction] = [],
    theme: PlaceholderTheme = .init()
  ) {
    self.theme = theme
    let buttons = actions.map {
      PlaceholderButton(
        title: $0.title, style: $0.role == .destructive ? .primary : .primary, action: $0.action)
    }
    self.configuration = theme.configuration(for: state, actions: buttons)
  }

  public init(
    configuration: PlaceholderConfiguration,
    theme: PlaceholderTheme = .init()
  ) {
    self.configuration = configuration
    self.theme = theme
  }

  public var body: some View {
    ZStack {
      theme.backgroundColor
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture { configuration.onBackgroundTap?() }

      VStack(spacing: 0) {
        if let media = configuration.media {
          PlaceholderMediaView(
            media: media,
            size: configuration.layout.mediaSize,
            tint: theme.mediaColor
          )
          .padding(.bottom, configuration.layout.spacing.afterMedia)
        }

        if let title = configuration.title {
          Text(title.value)
            .font(title.font ?? theme.titleFont)
            .foregroundStyle(title.color ?? theme.titleColor)
            .multilineTextAlignment(.center)
            .padding(.bottom, configuration.layout.spacing.afterTitle)
        }

        if let subtitle = configuration.subtitle {
          Text(subtitle.value)
            .font(subtitle.font ?? theme.subtitleFont)
            .foregroundStyle(subtitle.color ?? theme.subtitleColor)
            .multilineTextAlignment(.center)
            .padding(.bottom, configuration.layout.spacing.afterSubtitle)
        }

        if let button = configuration.primaryButton {
          PlaceholderButtonView(model: button)
            .padding(.bottom, configuration.layout.spacing.afterPrimaryButton)
        }

        if let button = configuration.secondaryButton {
          PlaceholderButtonView(model: button)
            .padding(.bottom, configuration.layout.spacing.afterSecondaryButton)
        }

        if let button = configuration.linkButton {
          PlaceholderButtonView(model: button)
        }

        if let customBottomView = configuration.customBottomView {
          customBottomView
        }
      }
      .padding(configuration.layout.contentInset)
      .frame(maxWidth: .infinity)
      .offset(y: configuration.layout.verticalOffset)
    }
  }
}
