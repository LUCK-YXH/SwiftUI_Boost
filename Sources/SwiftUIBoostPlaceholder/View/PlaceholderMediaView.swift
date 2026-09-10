import SwiftUI

struct PlaceholderMediaView: View {
  let media: PlaceholderMedia
  let size: CGSize?
  let tint: Color

  var body: some View {
    Group {
      switch media {
      case .systemImage(let name):
        Image(systemName: name)
          .font(.system(size: 46, weight: .regular))
          .foregroundStyle(tint)
      case .image(let image):
        image
          .resizable()
          .scaledToFit()
      case .loading:
        ProgressView()
          .progressViewStyle(.circular)
          .tint(tint)
      case .custom(let view):
        view
      }
    }
    .frame(width: size?.width, height: size?.height)
  }
}
