import XCTest

@testable import SwiftUIBoostNotices
@testable import SwiftUIBoostOverlay
@testable import SwiftUIBoostPager
@testable import SwiftUIBoostPlaceholder
@testable import SwiftUIBoostSkeleton

final class SwiftUIBoostTests: XCTestCase {

  func testBuzzmeSkeletonConfigurationUsesSoftNeutralDefaults() {
    let configuration = SkeletonConfiguration.buzzme

    XCTAssertEqual(configuration.cornerRadius, 8)
    XCTAssertEqual(configuration.animationDuration, 1.2, accuracy: 0.001)
    XCTAssertEqual(configuration.shimmerWidthRatio, 0.42, accuracy: 0.001)
  }

  func testSkeletonShimmerPhaseLoopsAcrossTheSharedClock() {
    let configuration = SkeletonConfiguration.buzzme

    XCTAssertEqual(configuration.shimmerPhase(at: 0), -1, accuracy: 0.001)
    XCTAssertEqual(configuration.shimmerPhase(at: configuration.animationDuration / 2), 0, accuracy: 0.001)
    XCTAssertEqual(configuration.shimmerPhase(at: configuration.animationDuration), -1, accuracy: 0.001)
  }

  func testSharedShimmerContainerIsAvailable() {
    _ = SkeletonShimmerContainer {
      SkeletonBlock(height: 16)
    }
  }

  func testSkeletonConfigurationCanTuneShimmer() {
    var configuration = SkeletonConfiguration.buzzme
    configuration.animationDuration = 0.8
    configuration.shimmerWidthRatio = 0.5

    XCTAssertEqual(configuration.animationDuration, 0.8, accuracy: 0.001)
    XCTAssertEqual(configuration.shimmerWidthRatio, 0.5, accuracy: 0.001)
  }

  func testPublicModulesAreAvailable() {
    _ = NoticeRequest("hello")
    _ = PlaceholderView(state: .empty)
    _ = SkeletonConfiguration()
    _ = SkeletonBlock(width: 120, height: 18)
    _ = SkeletonCircle(diameter: 44)
    _ = SkeletonCapsule(width: 72)
    _ = PagerConfiguration()
    _ = OverlayCoordinator()
  }

  func testOverlayRequestSupportsConfigurablePopupContent() {
    let request = OverlayRequest(
      style: .hero,
      icon: .system("checkmark.circle.fill"),
      title: "Saved",
      subtitle: "Your changes are ready.",
      actions: [
        OverlayAction("Cancel", style: .cancel),
        OverlayAction("Continue", style: .primary)
      ],
      buttonLayout: .horizontal,
      dismissOnBackgroundTap: false,
      showsCloseButton: true,
      allowsSwipeToDismiss: true
    )

    XCTAssertEqual(request.style, .hero)
    XCTAssertEqual(request.title, "Saved")
    XCTAssertEqual(request.subtitle, "Your changes are ready.")
    XCTAssertEqual(request.actions.map(\.title), ["Cancel", "Continue"])
    XCTAssertEqual(request.actions.map(\.style), [.cancel, .primary])
    XCTAssertEqual(request.buttonLayout, .horizontal)
    XCTAssertFalse(request.dismissOnBackgroundTap)
    XCTAssertTrue(request.showsCloseButton)
    XCTAssertTrue(request.allowsSwipeToDismiss)
  }

  func testOverlayRequestCanEmbedCustomContent() {
    let request = OverlayRequest.custom(
      style: .alert,
      title: "Custom",
      subtitle: "A configured header",
      dismissOnBackgroundTap: false
    ) {
      Text("Custom body")
    }

    XCTAssertEqual(request.style, .alert)
    XCTAssertEqual(request.title, "Custom")
    XCTAssertFalse(request.dismissOnBackgroundTap)
    XCTAssertNotNil(request.customContent)
  }

  @MainActor
  func testOldActionCannotDismissAReplacementPopup() {
    let coordinator = OverlayCoordinator()
    let replacement = OverlayRequest(title: "Replacement")
    let first = OverlayRequest(
      title: "First",
      actions: [
        OverlayAction("Replace") {
          coordinator.present(replacement)
          coordinator.dismiss(reason: .action)
        }
      ]
    )

    coordinator.present(first)
    let action = try! XCTUnwrap(coordinator.request?.actions.first)
    action.action()

    XCTAssertEqual(coordinator.request?.id, replacement.id)
  }
}
