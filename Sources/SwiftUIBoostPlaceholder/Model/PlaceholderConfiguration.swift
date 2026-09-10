import SwiftUI

public struct PlaceholderConfiguration {
  public var media: PlaceholderMedia?
  public var title: PlaceholderText?
  public var subtitle: PlaceholderText?
  public var primaryButton: PlaceholderButton?
  public var secondaryButton: PlaceholderButton?
  public var linkButton: PlaceholderButton?
  public var customBottomView: AnyView?
  public var layout: PlaceholderLayout
  public var onBackgroundTap: (() -> Void)?

  public init(
    media: PlaceholderMedia? = nil,
    title: PlaceholderText? = nil,
    subtitle: PlaceholderText? = nil,
    primaryButton: PlaceholderButton? = nil,
    secondaryButton: PlaceholderButton? = nil,
    linkButton: PlaceholderButton? = nil,
    customBottomView: AnyView? = nil,
    layout: PlaceholderLayout = .default,
    onBackgroundTap: (() -> Void)? = nil
  ) {
    self.media = media
    self.title = title
    self.subtitle = subtitle
    self.primaryButton = primaryButton
    self.secondaryButton = secondaryButton
    self.linkButton = linkButton
    self.customBottomView = customBottomView
    self.layout = layout
    self.onBackgroundTap = onBackgroundTap
  }

  public static func make(_ build: (inout PlaceholderConfiguration) -> Void)
    -> PlaceholderConfiguration
  {
    var configuration = PlaceholderConfiguration()
    build(&configuration)
    return configuration
  }

  public func merging(_ override: PlaceholderConfiguration?) -> PlaceholderConfiguration {
    guard let override else { return self }
    return PlaceholderConfiguration(
      media: override.media ?? media,
      title: override.title ?? title,
      subtitle: override.subtitle ?? subtitle,
      primaryButton: override.primaryButton ?? primaryButton,
      secondaryButton: override.secondaryButton ?? secondaryButton,
      linkButton: override.linkButton ?? linkButton,
      customBottomView: override.customBottomView ?? customBottomView,
      layout: override.layout,
      onBackgroundTap: override.onBackgroundTap ?? onBackgroundTap
    )
  }
}
