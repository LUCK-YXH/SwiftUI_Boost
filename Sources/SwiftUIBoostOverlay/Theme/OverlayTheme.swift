import SwiftUI

/// 覆盖层视觉 token，集中三种样式的颜色 / 字号 / 圆角 / 阴影，对齐 Buzzme 弹窗设计稿。
/// 默认值即设计稿取值；需要定制时构造 `OverlayTheme` 传入 `OverlayHost` / `boostOverlay`。
public struct OverlayTheme {

  // MARK: - Alert（居中，设计稿 342-1026）

  public struct Alert {
    public var cardColor = Color.white
    public var cornerRadius: CGFloat = 18
    public var width: CGFloat = 300
    public var dimOpacity: Double = 0.45

    public var shadowColor = Color.black.opacity(0.45)
    public var shadowRadius: CGFloat = 17
    public var shadowY: CGFloat = 16

    public var titleFont = Font.system(size: 18, weight: .bold)
    public var titleColor = Color(hex: 0x14171A)
    public var messageFont = Font.system(size: 13.5, weight: .regular)
    public var messageColor = Color(hex: 0x8A9099)
    /// Text 行距（设计稿行高 19 − 字号 13.5）。
    public var messageLineSpacing: CGFloat = 5.5

    public var buttonHeight: CGFloat = 44
    public var buttonCornerRadius: CGFloat = 22
    public var buttonFont = Font.system(size: 14, weight: .bold)
    public var cancelColor = Color(hex: 0xEEF0EA)
    public var cancelTextColor = Color(hex: 0x14171A)
    public var destructiveColor = Color(hex: 0xFF3B30)
    public var destructiveTextColor = Color.white
    public var defaultColor = Color(hex: 0x007AFF)
    public var defaultTextColor = Color.white

    public init() {}
  }

  // MARK: - Action sheet（底部，设计稿 342-990）

  public struct Sheet {
    public var cardColor = Color.white
    public var cornerRadius: CGFloat = 20
    public var horizontalInset: CGFloat = 8
    public var bottomInset: CGFloat = 8
    public var cardSpacing: CGFloat = 8
    public var dimOpacity: Double = 0.4

    public var shadowColor = Color.black.opacity(0.35)
    public var shadowRadius: CGFloat = 8
    public var shadowY: CGFloat = 6

    public var grabberColor = Color(hex: 0xC8CCC2)
    public var grabberSize = CGSize(width: 36, height: 5)

    public var rowInset: CGFloat = 28
    public var rowVerticalPadding: CGFloat = 14
    public var titleFont = Font.system(size: 15.5, weight: .medium)
    public var titleColor = Color(hex: 0x14171A)
    public var subtitleFont = Font.system(size: 12.5, weight: .regular)
    public var subtitleColor = Color(hex: 0x8A9099)
    public var destructiveColor = Color(hex: 0xFF3B30)
    public var separatorColor = Color(hex: 0xC8CCC2).opacity(0.6)
    public var highlightColor = Color.black.opacity(0.05)

    public var headerTitleFont = Font.system(size: 13, weight: .semibold)
    public var headerMessageFont = Font.system(size: 12.5, weight: .regular)
    public var headerColor = Color(hex: 0x8A9099)

    public var cancelCornerRadius: CGFloat = 18
    public var cancelHeight: CGFloat = 56
    public var cancelFont = Font.system(size: 16, weight: .bold)
    public var cancelTextColor = Color(hex: 0x007AFF)

    public init() {}
  }

  // MARK: - Hero（居中，图标徽章 + 主/次按钮，Figma 174-4100）

  public struct Hero {
    public var cardColor = Color.white
    public var cornerRadius: CGFloat = 22
    public var width: CGFloat = 310
    public var dimColor = Color(hex: 0x0A0C08)
    public var dimOpacity: Double = 0.45

    public var shadowColor = Color.black.opacity(0.18)
    public var shadowRadius: CGFloat = 24
    public var shadowY: CGFloat = 12

    public var iconSize: CGFloat = 52
    public var iconCornerRadius: CGFloat = 26
    public var iconGlyphSize: CGFloat = 26
    public var iconBackground = Color(hex: 0xFAF3E0)
    public var iconTint = Color(hex: 0x007AFF)

    public var titleFont = Font.system(size: 18, weight: .bold)
    public var titleColor = Color(hex: 0x14171A)
    public var messageFont = Font.system(size: 12.5, weight: .regular)
    public var messageColor = Color(hex: 0x8A9099)
    public var messageLineSpacing: CGFloat = 4.5

    public var primaryHeight: CGFloat = 41
    public var primaryCornerRadius: CGFloat = 16
    public var primaryFont = Font.system(size: 14, weight: .bold)
    public var primaryColor = Color(hex: 0x007AFF)
    public var primaryTextColor = Color.white

    public var secondaryHeight: CGFloat = 28
    public var secondaryFont = Font.system(size: 12.5, weight: .medium)
    public var secondaryColor = Color(hex: 0xA9AFB6)

    public init() {}
  }

  public var alert = Alert()
  public var sheet = Sheet()
  public var hero = Hero()

  public init() {}

  public static let `default` = OverlayTheme()
}

extension Color {
  /// 十六进制颜色初始化（如 `Color(hex: 0x14171A)`），仅供 Overlay 主题使用。
  init(hex: UInt32, opacity: Double = 1) {
    let red = Double((hex >> 16) & 0xFF) / 255
    let green = Double((hex >> 8) & 0xFF) / 255
    let blue = Double(hex & 0xFF) / 255
    self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
  }
}
