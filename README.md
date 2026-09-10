# SwiftUI_Boost

SwiftUI 常用 UI 能力的模块化仓库。实现以 SwiftUI 为主，不保留旧 UIKit 组件的功能名，按当前项目语义拆分为可按需导入的模块。

## 模块

| 模块 | 主要能力 | CocoaPods 子模块 |
| --- | --- | --- |
| `SwiftUIBoostNotices` | 普通提示、成功/失败/警告/信息提示、进度提示、自动消失、持久显示、队列/替换/堆叠、操作按钮 | `SwiftUIBoost/Notices` |
| `SwiftUIBoostPlaceholder` | 空内容、无网络、加载失败、无搜索结果、无权限、自定义操作 | `SwiftUIBoost/Placeholder` |
| `SwiftUIBoostSkeleton` | Buzzme 风格 placeholder redaction、渐变 shimmer、块/圆形/胶囊骨架组件 | `SwiftUIBoost/Skeleton` |
| `SwiftUIBoostPager` | 横向/纵向分页卡片、peek、间距、初始位置、方向配置 | `SwiftUIBoost/Pager` |
| `SwiftUIBoostOverlay` | Alert、Sheet、Hero 风格覆盖层、操作按钮、背景点击关闭 | `SwiftUIBoost/Overlay` |

## Swift Package

在 Xcode 中打开根目录的 `Package.swift`，可以开发和测试各个模块。

```swift
.product(name: "SwiftUIBoostNotices", package: "SwiftUIBoost")
.product(name: "SwiftUIBoostPlaceholder", package: "SwiftUIBoost")
.product(name: "SwiftUIBoostSkeleton", package: "SwiftUIBoost")
.product(name: "SwiftUIBoostPager", package: "SwiftUIBoost")
.product(name: "SwiftUIBoostOverlay", package: "SwiftUIBoost")
```

## CocoaPods 按需使用

```ruby
pod 'SwiftUIBoost/Notices', :path => '../SwiftUI_Boost'
pod 'SwiftUIBoost/Placeholder', :path => '../SwiftUI_Boost'
pod 'SwiftUIBoost/Skeleton', :path => '../SwiftUI_Boost'
pod 'SwiftUIBoost/Pager', :path => '../SwiftUI_Boost'
pod 'SwiftUIBoost/Overlay', :path => '../SwiftUI_Boost'
```

## SwiftUI 示例

```swift
import SwiftUIBoostNotices

struct Screen: View {
    @StateObject private var notices = NoticeCenter()

    var body: some View {
        Button("完成") {
            notices.present(.init("操作成功", kind: .success))
        }
        .noticeWindowHost(notices)
    }
}
```

示例页面源码位于 `Example/SwiftUIBoostExample`，可直接打开 `Example/SwiftUIBoostExample.xcodeproj` 运行。

### Buzzme 风格骨架屏

`SkeletonConfiguration.buzzme` 提供低对比度中性底色、连续 shimmer 和较柔和的圆角，适合信息流、卡片和详情页的加载状态。骨架组件会保留原有 SwiftUI 布局尺寸，避免加载态和内容态切换时发生跳动。

当一个页面包含多个骨架组件时，推荐使用 `SkeletonShimmerContainer` 共享动画时钟，让所有占位内容保持同一条横向 shimmer 节奏：

```swift
SkeletonShimmerContainer {
    VStack {
        SkeletonCircle(diameter: 44)
        SkeletonBlock(height: 18)
        SkeletonCapsule(width: 72)
    }
}
```

```swift
import SwiftUI
import SwiftUIBoostSkeleton

struct FeedSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                SkeletonCircle(diameter: 42)
                VStack(alignment: .leading, spacing: 7) {
                    SkeletonBlock(width: 112, height: 13, cornerRadius: 6)
                    SkeletonBlock(width: 76, height: 11, cornerRadius: 6)
                }
            }

            SkeletonBlock(height: 180, cornerRadius: 12)
            SkeletonCapsule(width: 56, height: 24)
        }
        .padding(14)
    }
}
```

也可以对现有内容直接调用 `.skeleton(isLoading)`，在保持布局的同时显示骨架态：

```swift
contentView.skeleton(isLoading, configuration: .buzzme)
```

> 注意：根目录的 `Package.swift` 是 iOS 模块包，不是可执行 App；请使用示例工程打开并选择 iOS Simulator 或真机运行。示例工程通过本地 Swift Package 依赖根目录包，并已配置 iOS 15.0。

后续继续增加功能时，保持“一个能力一个 Swift Package target + 一个 CocoaPods subspec”的结构。

## 代码组织

每个能力按职责拆分，避免单文件承载全部实现：

```text
Sources/
├── SwiftUIBoostNotices/
│   ├── Model/NoticeTypes.swift
│   ├── State/NoticeCenter.swift
│   └── View/NoticeHost.swift
├── SwiftUIBoostPlaceholder/
│   ├── Model/PlaceholderTypes.swift
│   └── View/PlaceholderView.swift
├── SwiftUIBoostSkeleton/
│   ├── Model/SkeletonConfiguration.swift
│   └── View/SkeletonModifier.swift
├── SwiftUIBoostPager/
│   ├── Model/PagerConfiguration.swift
│   └── View/PagerView.swift
└── SwiftUIBoostOverlay/
    ├── Model/OverlayTypes.swift
    ├── State/OverlayCoordinator.swift
    └── View/OverlayHost.swift
```

Model、状态管理和 View 分开，后续扩展主题、动画、数据源和测试时可以继续在对应目录增加文件。

## 提示能力完整迁移说明

`SwiftUIBoostNotices` 已覆盖原提示组件的公开能力，但采用 SwiftUI 命名和实现：

- 文本、图标、加载、进度、操作按钮、自定义 View 内容
- 自动时长、指定时长、持久显示
- 顶部、中间、底部位置
- 淡入、滑入、缩放和无动画
- 队列、替换、堆叠
- 点击关闭、滑动关闭
- 主题、样式、圆角、内边距、Material 背景、最大宽度
- Token 文本更新、进度更新、完成并自动关闭
- 同步 API、Builder API、异步任务 API

示例：

```swift
let token = NoticeService.progress("上传中")
token.update(0.5)
token.finish("上传完成")

let confirmed = await NoticeService.action("删除文件？", title: "删除")
```

### 加载遮罩

原有的全屏/容器 loading 也已使用 SwiftUI 重写：

```swift
@StateObject private var loading = LoadingCoordinator()

var body: some View {
    ContentView()
        .loadingHost(loading)
        .onAppear {
            let handle = loading.show(.init(text: "加载中…"))
            // handle.dismiss()
        }
}
```

新的 loading 句柄具有身份校验：旧 loading 被新的 loading 替换后，旧句柄调用 `dismiss()` 不会关闭新的 loading。


## Window 级提示

Toast 默认由组件内部的单例 `NoticeWindowPresenter` 管理独立 `UIWindow`，业务侧只需在 App 根节点安装一次：

```swift
WindowGroup {
    RootView()
        .environmentObject(notices)
        .noticeWindowHost(notices)
}
```

之后在任意子页面通过 `@EnvironmentObject` 使用同一个 `NoticeCenter`，不需要重复创建 Window 或 NoticeCenter。
