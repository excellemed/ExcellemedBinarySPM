#if os(iOS)

import UIKit

@MainActor
public final class LoadingCheckboxActivityIndicator: BaseLottieActivityIndicator {
  public init() {
    super.init(
      zoomScale: 1.7,
      hidesWhenStopped: true,
      clipsToBounds: true
    )
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

#endif
