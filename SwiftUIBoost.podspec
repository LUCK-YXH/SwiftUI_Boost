Pod::Spec.new do |s|
  s.name             = 'SwiftUIBoost'
  s.version          = '0.1.0'
  s.summary          = 'Modular SwiftUI components for common UI states and interactions.'
  s.description      = 'SwiftUI modules for notices, placeholders, skeleton loading, paging and overlays.'
  s.homepage         = 'https://github.com/your-org/SwiftUI_Boost'
  s.license          = { :type => 'MIT' }
  s.author           = { 'SwiftUIBoost' => 'your-email@example.com' }
  s.source           = { :git => 'https://github.com/your-org/SwiftUI_Boost.git', :tag => s.version.to_s }
  s.swift_version    = '5.9'
  s.ios.deployment_target = '15.0'
  s.default_subspecs = []

  s.subspec 'Notices' do |mod|
    mod.source_files = 'Sources/SwiftUIBoostNotices/**/*.swift'
  end
  s.subspec 'Placeholder' do |mod|
    mod.source_files = 'Sources/SwiftUIBoostPlaceholder/**/*.swift'
  end
  s.subspec 'Skeleton' do |mod|
    mod.source_files = 'Sources/SwiftUIBoostSkeleton/**/*.swift'
  end
  s.subspec 'Pager' do |mod|
    mod.source_files = 'Sources/SwiftUIBoostPager/**/*.swift'
  end
  s.subspec 'Overlay' do |mod|
    mod.source_files = 'Sources/SwiftUIBoostOverlay/**/*.swift'
  end
end
