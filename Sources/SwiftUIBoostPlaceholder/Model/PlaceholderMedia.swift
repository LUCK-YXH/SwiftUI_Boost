import SwiftUI

public enum PlaceholderMedia {
  case systemImage(String)
  case image(Image)
  case loading
  case custom(AnyView)
}
