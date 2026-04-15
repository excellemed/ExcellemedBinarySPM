#if os(iOS)

import Lottie
import UIKit

public class BluetoothScanIndicator: UIView {
  private let animationView: LottieAnimationView
  internal var hidesWhenStopped: Bool = false

  internal var isHide = false {
    didSet {
      isHidden = isHide
    }
  }

  public init() {
    let path = Bundle.module.path(forResource: "bluetooth_connecting", ofType: "json")!
    self.animationView = LottieAnimationView(filePath: path)
    super.init(frame: .zero)
    setup()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    animationView.translatesAutoresizingMaskIntoConstraints = false
    animationView.contentMode = .scaleAspectFit
    animationView.loopMode = .loop
    addSubview(animationView)
    NSLayoutConstraint.activate([
      animationView.leadingAnchor.constraint(equalTo: leadingAnchor),
      animationView.trailingAnchor.constraint(equalTo: trailingAnchor),
      animationView.bottomAnchor.constraint(equalTo: bottomAnchor),
      animationView.topAnchor.constraint(equalTo: topAnchor),
    ])
    isHidden = false
  }
}

extension BluetoothScanIndicator: CustomActivityIndicator {
  public var isAnimating: Bool { animationView.isAnimationPlaying }

  public func stopAnimating() {
    animationView.stop()
    isHidden = hidesWhenStopped
  }

  public func startAnimating() {
    animationView.play()
    isHidden = false
  }
}

#endif
