import SwiftUI

public enum PlaceholderState {
  case empty
  case offline
  case failure(Error?)
  case loading
  case noResults(keyword: String?)
  case restricted
  case custom(PlaceholderConfiguration)
}
