import SwiftUI
import SwiftUIBoostNotices
import SwiftUIBoostOverlay
import SwiftUIBoostPlaceholder
import SwiftUIBoostSkeleton

struct ContentView: View {
  @EnvironmentObject private var notices: NoticeCenter
  @StateObject private var rootNotices = NoticeCenter()
  @StateObject private var loading = LoadingCoordinator()
  @StateObject private var overlays = OverlayCoordinator()
  @State private var selectedTab: DemoTab = .notices

  var body: some View {
    TabView(selection: $selectedTab) {
      NavigationView {
        NoticeDemoView(
          rootNotices: rootNotices,
          loading: loading
        )
        .navigationTitle("Toast")
        .navigationBarTitleDisplayMode(.inline)
      }
      .tabItem {
        Label("Toast", systemImage: "bell.badge")
      }
      .tag(DemoTab.notices)

      NavigationView {
        PlaceholderDemoView()
          .navigationTitle("缺省状态")
          .navigationBarTitleDisplayMode(.inline)
      }
      .tabItem {
        Label("缺省", systemImage: "rectangle.slash")
      }
      .tag(DemoTab.placeholder)

      NavigationView {
        SkeletonDemoView()
          .navigationTitle("骨架屏")
          .navigationBarTitleDisplayMode(.inline)
      }
      .tabItem {
        Label("骨架屏", systemImage: "rectangle.stack")
      }
      .tag(DemoTab.skeleton)

      NavigationView {
        ComponentsDemoView(overlays: overlays)
          .navigationTitle("组件")
          .navigationBarTitleDisplayMode(.inline)
      }
      .tabItem {
        Label("组件", systemImage: "square.grid.2x2")
      }
      .tag(DemoTab.components)
    }
    .loadingHost(loading)
    .boostOverlay(overlays)
    .noticeHost(rootNotices)
    .preferredColorScheme(.dark)
  }
}

private enum DemoTab: Hashable {
  case notices
  case placeholder
  case skeleton
  case components
}

private struct NoticeDemoView: View {
  @EnvironmentObject private var notices: NoticeCenter
  let rootNotices: NoticeCenter
  let loading: LoadingCoordinator

  var body: some View {
    List {
      Section {
        Text("当前页面同时演示三种容器：UIWindow、根视图和指定 View。")
          .font(.footnote)
          .foregroundStyle(.secondary)
      }

      Section("展示容器") {
        NoticeDemoButton("UIWindow：全局 Toast", systemImage: "macwindow") {
          _ = notices.success("来自独立 UIWindow 的 Toast")
        }
        NoticeDemoButton("根视图：全局 Toast", systemImage: "rectangle.inset.filled") {
          _ = rootNotices.information("来自 SwiftUI 根视图的 Toast")
        }
        NavigationLink {
          LocalNoticeDemoView()
        } label: {
          Label("指定 View：局部 Toast", systemImage: "rectangle.inset.filled.and.person.filled")
        }
      }

      Section("基础类型") {
        NoticeDemoButton("普通文本", systemImage: "text.bubble") {
          _ = notices.show("这是一条普通提示")
        }
        NoticeDemoButton("成功", systemImage: "checkmark.circle.fill") {
          _ = notices.success("保存成功")
        }
        NoticeDemoButton("失败", systemImage: "xmark.circle.fill") {
          _ = notices.failure("保存失败，请稍后重试")
        }
        NoticeDemoButton("警告", systemImage: "exclamationmark.triangle.fill") {
          _ = notices.warning("当前操作可能影响已有数据")
        }
        NoticeDemoButton("信息", systemImage: "info.circle.fill") {
          _ = notices.information("新的内容已经准备好了")
        }
      }

      Section("加载和进度") {
        NoticeDemoButton("加载提示", systemImage: "hourglass") {
          _ = notices.loading("正在加载")
        }
        NoticeDemoButton("进度提示", systemImage: "chart.bar.fill") {
          showProgress()
        }
        NoticeDemoButton("全屏 Loading", systemImage: "circle.dotted.circle") {
          _ = loading.show(.init(text: "请稍候…"))
        }
        NoticeDemoButton("关闭 Loading", systemImage: "xmark") {
          loading.dismiss()
        }
        NoticeDemoButton("关闭当前 Toast", systemImage: "minus.circle") {
          notices.dismissCurrent()
        }
        NoticeDemoButton("关闭全部 Toast", systemImage: "xmark.circle") {
          notices.dismissAll()
        }
      }

      Section("交互和队列") {
        NoticeDemoButton("操作按钮", systemImage: "hand.tap") {
          _ = notices.action("发现新版本", title: "查看") {
            _ = notices.information("正在打开更新页面")
          }
        }
        NoticeDemoButton("滑动关闭", systemImage: "arrow.left.and.right") {
          var options = NoticePartialOptions()
          options.swipeToDismiss = true
          _ = notices.present(
            notices.configuration.request(
              content: .icon(.information, "向任意方向滑动可关闭"),
              options: options
            )
          )
        }
        NoticeDemoButton("Builder 配置", systemImage: "slider.horizontal.3") {
          _ = NoticeService.make("Builder 创建的提示")
            .icon(.success)
            .placement(.top)
            .duration(.seconds(4))
            .animation(.scale)
            .queue(.stack)
            .show(in: notices)
        }
        NoticeDemoButton("连续队列", systemImage: "list.number") {
          for index in 1...3 {
            _ = notices.present(
              notices.configuration.request(content: .text("队列中的第 \(index) 条提示"))
            )
          }
        }
        NoticeDemoButton("替换当前提示", systemImage: "arrow.triangle.2.circlepath") {
          var options = NoticePartialOptions()
          options.queue = .replace
          _ = notices.present(
            notices.configuration.request(
              content: .icon(.warning, "当前提示已被替换"),
              options: options
            )
          )
        }
      }

      Section("异步") {
        NoticeDemoButton("异步任务", systemImage: "arrow.triangle.2.circlepath.circle") {
          Task { @MainActor in
            let token = notices.loading("请求处理中")
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            token.dismiss()
            _ = notices.success("请求完成")
          }
        }
        NoticeDemoButton("异步操作确认", systemImage: "questionmark.circle") {
          Task { @MainActor in
            let confirmed = await noticeAction(notices)
            _ = notices.information(confirmed ? "用户确认了操作" : "用户取消了操作")
          }
        }
      }
    }
  }

  private func showProgress() {
    let token = notices.progress("正在上传")
    Task { @MainActor in
      for step in 1...10 {
        try? await Task.sleep(nanoseconds: 160_000_000)
        token.update(Double(step) / 10)
      }
      token.finish("上传完成")
    }
  }
}

private struct LocalNoticeDemoView: View {
  @StateObject private var notices = NoticeCenter()

  var body: some View {
    VStack(spacing: 20) {
      Image(systemName: "rectangle.inset.filled.and.person.filled")
        .font(.system(size: 46))
        .foregroundStyle(.blue)
      Text("这个 Toast 只挂载在当前页面")
        .font(.headline)
      Text("返回上一级后，局部 NoticeCenter 和它的 Toast 一起销毁。")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
      Button("显示局部成功 Toast") {
        _ = notices.success("局部页面操作成功")
      }
      .buttonStyle(.borderedProminent)
      Button("显示局部错误 Toast") {
        _ = notices.failure("局部页面操作失败")
      }
      .buttonStyle(.bordered)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .navigationTitle("指定 View Toast")
    .noticeHost(notices)
  }
}

private struct PlaceholderDemoView: View {
  var body: some View {
    List {
      Section {
        Text("每个状态都对应一个可单独定制的 SwiftUI 配置。")
          .font(.footnote)
          .foregroundStyle(.secondary)
      }
      Section("标准状态") {
        PlaceholderLink(title: "空内容", systemImage: "tray") {
          PlaceholderDemoScreen(title: "空内容", configuration: .empty)
        }
        PlaceholderLink(title: "无网络", systemImage: "wifi.slash") {
          PlaceholderDemoScreen(title: "无网络", configuration: .offline)
        }
        PlaceholderLink(title: "错误状态", systemImage: "exclamationmark.circle") {
          PlaceholderDemoScreen(title: "错误", configuration: .failure)
        }
        PlaceholderLink(title: "加载状态", systemImage: "hourglass") {
          PlaceholderDemoScreen(title: "加载中", configuration: .loading)
        }
        PlaceholderLink(title: "无搜索结果", systemImage: "magnifyingglass") {
          PlaceholderDemoScreen(title: "无搜索结果", configuration: .noResults)
        }
        PlaceholderLink(title: "无权限", systemImage: "lock") {
          PlaceholderDemoScreen(title: "无权限", configuration: .restricted)
        }
      }
      Section("自定义配置") {
        NavigationLink("主按钮 / 次按钮 / 链接按钮") {
          PlaceholderDemoScreen(title: "自定义按钮", configuration: .customButtons)
        }
        NavigationLink("自定义底部内容和布局") {
          PlaceholderDemoScreen(title: "自定义内容", configuration: .customContent)
        }
      }
    }
  }
}

private struct PlaceholderLink<Destination: View>: View {
  let title: String
  let systemImage: String
  let destination: () -> Destination

  var body: some View {
    NavigationLink(destination: destination()) {
      Label(title, systemImage: systemImage)
    }
  }
}

private final class PlaceholderDemoFeedback: ObservableObject {
  @Published var message = ""
  @Published var isPresented = false

  func show(_ message: String) {
    self.message = message
    isPresented = true
  }
}

private struct PlaceholderDemoScreen: View {
  enum ConfigurationKind {
    case empty, offline, failure, loading, noResults, restricted, customButtons, customContent
  }

  let title: String
  let configuration: ConfigurationKind
  @StateObject private var feedback = PlaceholderDemoFeedback()

  var body: some View {
    PlaceholderView(configuration: makeConfiguration())
      .navigationTitle(title)
      .alert(isPresented: $feedback.isPresented) {
        Alert(
          title: Text("操作反馈"),
          message: Text(feedback.message),
          dismissButton: .default(Text("确定"))
        )
      }
  }

  private func makeConfiguration() -> PlaceholderConfiguration {
    switch configuration {
    case .empty:
      return .make {
        $0.media = .systemImage("tray")
        $0.title = .init("暂无内容")
        $0.subtitle = .init("创建第一条内容后，它会显示在这里")
        $0.primaryButton = .init(title: "创建内容") { feedback.show("已点击：创建内容") }
      }
    case .offline:
      return .make {
        $0.media = .systemImage("wifi.slash")
        $0.title = .init("网络不可用")
        $0.subtitle = .init("请检查网络连接后重试")
        $0.primaryButton = .init(title: "重试") { feedback.show("已点击：重试") }
      }
    case .failure:
      return .make {
        $0.media = .systemImage("exclamationmark.circle")
        $0.title = .init("加载失败")
        $0.primaryButton = .init(title: "重新加载") { feedback.show("已点击：重新加载") }
        $0.secondaryButton = .init(title: "返回", style: .secondary) { feedback.show("已点击：返回") }
      }
    case .loading:
      return .make {
        $0.media = .loading
        $0.title = .init("正在加载")
      }
    case .noResults:
      return .make {
        $0.media = .systemImage("magnifyingglass")
        $0.title = .init("没有找到结果")
        $0.subtitle = .init("未找到与“SwiftUI”相关的内容")
        $0.linkButton = .init(title: "清除搜索条件", style: .link) { feedback.show("已点击：清除搜索条件") }
      }
    case .restricted:
      return .make {
        $0.media = .systemImage("lock")
        $0.title = .init("暂无权限")
        $0.subtitle = .init("登录后即可继续使用")
        $0.primaryButton = .init(title: "登录") { feedback.show("已点击：登录") }
      }
    case .customButtons:
      return .make {
        $0.media = .systemImage("sparkles")
        $0.title = .init("欢迎使用")
        $0.subtitle = .init("这里展示三种按钮样式")
        $0.primaryButton = .init(title: "主要操作") { feedback.show("已点击：主要操作") }
        $0.secondaryButton = .init(title: "次要操作", style: .secondary) { feedback.show("已点击：次要操作") }
        $0.linkButton = .init(title: "了解更多", style: .link) { feedback.show("已点击：了解更多") }
      }
    case .customContent:
      return .make {
        $0.media = .systemImage("slider.horizontal.3")
        $0.title = .init("自定义内容")
        $0.subtitle = .init("支持自定义布局、媒体尺寸和底部 View")
        $0.customBottomView = AnyView(
          Button("点击自定义底部 View") {
            feedback.show("已点击：自定义底部 View")
          }
          .font(.footnote)
          .foregroundStyle(.blue)
        )
        $0.layout = .init(
          verticalOffset: -16,
          mediaSize: .init(width: 72, height: 72),
          spacing: .init(afterMedia: 20, afterTitle: 10, afterSubtitle: 18),
          contentInset: .init(top: 0, leading: 32, bottom: 0, trailing: 32)
        )
        $0.onBackgroundTap = {
          feedback.show("已点击缺省状态背景")
        }
      }
    }
  }
}

private struct SkeletonDemoView: View {
  var body: some View {
    List {
      Section {
        Text("独立展示不同骨架屏组合，方便对比基础组件、信息流和详情卡片的占位效果。")
          .font(.footnote)
          .foregroundStyle(.secondary)
      }

      Section("信息流") {
        NavigationLink {
          BuzzmeSkeletonDemoView()
            .navigationTitle("Buzzme 信息流")
            .navigationBarTitleDisplayMode(.inline)
        } label: {
          Label("Buzzme 信息流", systemImage: "rectangle.stack")
        }
      }

      Section("基础组件") {
        NavigationLink("块、圆形和胶囊") {
          SkeletonPrimitivesDemoView()
            .navigationTitle("基础组件")
            .navigationBarTitleDisplayMode(.inline)
        }
        NavigationLink("详情卡片") {
          SkeletonDetailDemoView()
            .navigationTitle("详情卡片")
            .navigationBarTitleDisplayMode(.inline)
        }
        NavigationLink("修饰器对齐内容") {
          SkeletonModifierDemoView()
            .navigationTitle("修饰器")
            .navigationBarTitleDisplayMode(.inline)
        }
      }
    }
  }
}

private struct SkeletonPrimitivesDemoView: View {
  var body: some View {
    SkeletonShimmerContainer {
      VStack(alignment: .leading, spacing: 18) {
        SkeletonBlock(height: 18)
        SkeletonBlock(width: 220, height: 18)
        HStack(spacing: 14) {
          SkeletonCircle(diameter: 52)
          SkeletonCircle(diameter: 36)
          SkeletonCapsule(width: 96, height: 30)
        }
        SkeletonBlock(height: 120, cornerRadius: 12)
        Spacer()
      }
      .padding(20)
    }
  }
}

private struct SkeletonDetailDemoView: View {
  var body: some View {
    SkeletonShimmerContainer {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          SkeletonBlock(height: 220, cornerRadius: 16)
          SkeletonBlock(width: 240, height: 24, cornerRadius: 8)
          SkeletonBlock(width: 140, height: 14, cornerRadius: 7)
          VStack(alignment: .leading, spacing: 9) {
            SkeletonBlock(height: 14, cornerRadius: 7)
            SkeletonBlock(height: 14, cornerRadius: 7)
            SkeletonBlock(width: 260, height: 14, cornerRadius: 7)
          }
          HStack {
            SkeletonCapsule(width: 100, height: 38)
            SkeletonCapsule(width: 100, height: 38)
          }
        }
        .padding(16)
      }
      .background(Color(.systemGroupedBackground))
    }
  }
}

private struct SkeletonModifierDemoView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Buzzme 的标题内容")
        .font(.title2.bold())
      Text("使用同一套布局，在真实数据到达前显示占位状态，避免页面跳动。")
        .foregroundStyle(.secondary)
      HStack {
        Image(systemName: "person.crop.circle.fill")
          .font(.largeTitle)
        Text("作者名称")
        Spacer()
      }
    }
    .padding(20)
    .skeleton()
  }
}

private struct BuzzmeSkeletonDemoView: View {
  private let configuration = SkeletonConfiguration.buzzme

  var body: some View {
    SkeletonShimmerContainer(configuration: configuration) {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          ForEach(0..<4, id: \.self) { _ in
            BuzzmeSkeletonPost(configuration: configuration)
          }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
      }
      .background(Color(.systemGroupedBackground))
    }
  }
}

private struct BuzzmeSkeletonPost: View {
  let configuration: SkeletonConfiguration

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack(spacing: 10) {
        SkeletonCircle(diameter: 42, configuration: configuration)
        VStack(alignment: .leading, spacing: 7) {
          SkeletonBlock(width: 112, height: 13, cornerRadius: 6, configuration: configuration)
          SkeletonBlock(width: 76, height: 11, cornerRadius: 6, configuration: configuration)
        }
        Spacer()
        SkeletonCapsule(width: 52, height: 26, configuration: configuration)
      }

      VStack(alignment: .leading, spacing: 8) {
        SkeletonBlock(height: 14, cornerRadius: 7, configuration: configuration)
        SkeletonBlock(width: 236, height: 14, cornerRadius: 7, configuration: configuration)
        SkeletonBlock(width: 178, height: 14, cornerRadius: 7, configuration: configuration)
      }

      SkeletonBlock(height: 180, cornerRadius: 12, configuration: configuration)

      HStack(spacing: 18) {
        SkeletonCapsule(width: 56, height: 24, configuration: configuration)
        SkeletonCapsule(width: 56, height: 24, configuration: configuration)
        SkeletonCapsule(width: 56, height: 24, configuration: configuration)
        Spacer()
      }
    }
    .padding(14)
    .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
  }
}

private struct ComponentsDemoView: View {
  let overlays: OverlayCoordinator

  var body: some View {
    List {
      Section("Alert 居中弹窗") {
        Button("确认 / 取消") {
          overlays.present(
            .init(
              title: "Block Maya?",
              subtitle: "She won't be able to reach you or see your profile.",
              actions: [
                .init("Cancel", style: .cancel),
                .init("Block", style: .destructive) {}
              ],
              dismissOnBackgroundTap: false
            )
          )
        }
        Button("单个操作") {
          overlays.present(
            .init(
              title: "已保存",
              subtitle: "你的修改已经同步到云端。",
              actions: [.init("知道了", style: .primary) {}]
            )
          )
        }
      }

      Section("Action Sheet 底部面板") {
        Button("带副标题的行 + Cancel 卡") {
          overlays.present(
            .init(
              style: .actionSheet,
              actions: [
                .init("View profile") {},
                .init(
                  "Block Maya",
                  subtitle: "She won't be able to reach you",
                  style: .destructive
                ) {},
                .init("Report", subtitle: "Let us know what's wrong") {},
                .init("Cancel", style: .cancel)
              ]
            )
          )
        }
      }

      Section("Hero 图标弹窗") {
        Button("图标徽章 + 主/次按钮") {
          overlays.present(
            .init(
              style: .hero,
              icon: .system("bell.badge.fill"),
              iconBackground: Color(red: 0.98, green: 0.95, blue: 0.88),
              title: "Turn on alerts?",
              subtitle: "Get notified the moment someone buzzes you.",
              actions: [
                .init("Not now", style: .cancel),
                .init("Allow", style: .primary) {}
              ]
            )
          )
        }
      }
    }
  }
}

@MainActor
private func noticeAction(_ notices: NoticeCenter) async -> Bool {
  await withCheckedContinuation { continuation in
    var tapped = false
    let token = notices.action("确认执行这个操作吗？", title: "确认") {
      tapped = true
    }
    Task {
      await token.waitUntilDismissed()
      continuation.resume(returning: tapped)
    }
  }
}

private struct NoticeDemoButton: View {
  let title: String
  let systemImage: String
  let action: () -> Void

  init(_ title: String, systemImage: String, action: @escaping () -> Void) {
    self.title = title
    self.systemImage = systemImage
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      Label(title, systemImage: systemImage)
    }
  }
}

#Preview {
  ContentView()
    .environmentObject(NoticeCenter.shared)
}
