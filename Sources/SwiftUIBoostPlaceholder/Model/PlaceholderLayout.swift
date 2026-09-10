import SwiftUI

public struct PlaceholderLayout {
  public struct Spacing {
    public var afterMedia: CGFloat
    public var afterTitle: CGFloat
    public var afterSubtitle: CGFloat
    public var afterPrimaryButton: CGFloat
    public var afterSecondaryButton: CGFloat

    public init(
      afterMedia: CGFloat = 16,
      afterTitle: CGFloat = 8,
      afterSubtitle: CGFloat = 24,
      afterPrimaryButton: CGFloat = 12,
      afterSecondaryButton: CGFloat = 0
    ) {
      self.afterMedia = afterMedia
      self.afterTitle = afterTitle
      self.afterSubtitle = afterSubtitle
      self.afterPrimaryButton = afterPrimaryButton
      self.afterSecondaryButton = afterSecondaryButton
    }
  }

  public var verticalOffset: CGFloat
  public var mediaSize: CGSize?
  public var spacing: Spacing
  public var contentInset: EdgeInsets

  public init(
    verticalOffset: CGFloat = 0,
    mediaSize: CGSize? = nil,
    spacing: Spacing = .init(),
    contentInset: EdgeInsets = .init(top: 0, leading: 24, bottom: 0, trailing: 24)
  ) {
    self.verticalOffset = verticalOffset
    self.mediaSize = mediaSize
    self.spacing = spacing
    self.contentInset = contentInset
  }

  public static let `default` = PlaceholderLayout()
}
