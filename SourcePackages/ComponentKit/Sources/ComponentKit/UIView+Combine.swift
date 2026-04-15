#if canImport(UIKit)

import UIKit

extension UIView: CombineCompatible {}

extension UIViewController: CombineCompatible {}

public extension Reactive where Base: UIView {
  var isAnimating: Binder<Bool> {
    Binder(base) { v, shouldAnimate in
      if shouldAnimate {
        v.makeToastActivity(.center)
      } else {
        v.hideToastActivity()
      }
    }
  }
}

extension Reactive where Base: BluetoothScanIndicator {
  @MainActor
  public var isAnimating: Binder<Bool> {
    Binder(base) { activityIndicator, shouldAnimate in
      if shouldAnimate {
        activityIndicator.startAnimating()
      } else {
        activityIndicator.stopAnimating()
      }
    }
  }
}

extension Reactive where Base: LottieActivityIndicator {
  @MainActor
  public var isAnimating: Binder<Bool> {
    Binder(base) { activityIndicator, shouldAnimate in
      if shouldAnimate {
        activityIndicator.startAnimating()
      } else {
        activityIndicator.stopAnimating()
      }
    }
  }
}

#endif
