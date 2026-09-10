import SwiftUI

public struct PlaceholderTheme {
  public enum Preset: Hashable {
    case empty
    case offline
    case failure
    case loading
    case noResults
    case restricted
  }

  public var titleFont: Font = .system(size: 17, weight: .semibold)
  public var subtitleFont: Font = .system(size: 14)
  public var titleColor: Color = .white
  public var subtitleColor: Color = Color.white.opacity(0.68)
  public var mediaColor: Color = Color(red: 0.35, green: 0.68, blue: 1.0)
  public var backgroundColor: Color = Color(red: 0.07, green: 0.08, blue: 0.10)
  public var retryTitle = "重试"
  public var signInTitle = "登录"
  public var presets: [Preset: PlaceholderConfiguration] = [:]

  public init() {}

  public mutating func setPreset(
    _ preset: Preset,
    _ build: (inout PlaceholderConfiguration) -> Void
  ) {
    var configuration = presets[preset] ?? .init()
    build(&configuration)
    presets[preset] = configuration
  }

  public func configuration(
    for state: PlaceholderState,
    actions: [PlaceholderButton] = []
  ) -> PlaceholderConfiguration {
    var configuration: PlaceholderConfiguration

    switch state {
    case .custom(let custom):
      configuration = custom
    case .empty:
      configuration =
        presets[.empty]
        ?? .make {
          $0.media = .systemImage("tray")
          $0.title = .init("暂无内容")
        }
    case .offline:
      configuration =
        presets[.offline]
        ?? .make {
          $0.media = .systemImage("wifi.slash")
          $0.title = .init("网络不可用")
          $0.subtitle = .init("请检查网络连接后重试")
          $0.primaryButton = .init(title: retryTitle)
        }
    case .failure:
      configuration =
        presets[.failure]
        ?? .make {
          $0.media = .systemImage("exclamationmark.circle")
          $0.title = .init("加载失败")
          $0.primaryButton = .init(title: retryTitle)
        }
    case .loading:
      configuration =
        presets[.loading]
        ?? .make {
          $0.media = .loading
          $0.title = .init("正在加载")
        }
    case .noResults(let keyword):
      configuration =
        presets[.noResults]
        ?? .make {
          $0.media = .systemImage("magnifyingglass")
          $0.title = .init("没有找到结果")
        }
      let value = keyword ?? ""
      configuration.subtitle = .init("未找到与“\(value)”相关的内容")
    case .restricted:
      configuration =
        presets[.restricted]
        ?? .make {
          $0.media = .systemImage("lock")
          $0.title = .init("暂无权限")
          $0.primaryButton = .init(title: signInTitle)
        }
    }

    if !actions.isEmpty {
      configuration.primaryButton = actions.first
      configuration.secondaryButton = actions.dropFirst().first
      configuration.linkButton = actions.dropFirst(2).first
    }
    return configuration
  }
}
