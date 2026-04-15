#if os(iOS)

import Lottie
import UIKit

@MainActor
public protocol CustomActivityIndicator {
  func startAnimating()
  func stopAnimating()
  var isAnimating: Bool { get }
}

open class BaseLottieActivityIndicator: UIView, CustomActivityIndicator {
  private let animationView: LottieAnimationView
  public var hidesWhenStopped: Bool
  public var zoomScale: CGFloat {
    didSet { setNeedsLayout() }
  }
  private let defaultSize: CGSize?

  public init(
    resourceName: String = "loading",
    defaultSize: CGSize? = nil,
    zoomScale: CGFloat = 1.0,
    hidesWhenStopped: Bool = false,
    clipsToBounds: Bool = false,
    contentMode: UIView.ContentMode = .scaleAspectFit,
    loopMode: LottieLoopMode = .loop
  ) {
    let path = Bundle.module.path(forResource: resourceName, ofType: "json")!
    self.animationView = LottieAnimationView(filePath: path)
    self.defaultSize = defaultSize
    self.zoomScale = zoomScale
    self.hidesWhenStopped = hidesWhenStopped
    super.init(frame: CGRect(origin: .zero, size: defaultSize ?? .zero))
    self.clipsToBounds = clipsToBounds
    animationView.contentMode = contentMode
    animationView.loopMode = loopMode
    addSubview(animationView)
    isHidden = hidesWhenStopped
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override var intrinsicContentSize: CGSize {
    defaultSize ?? CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    let width = bounds.width * zoomScale
    let height = bounds.height * zoomScale
    animationView.frame = CGRect(
      x: (bounds.width - width) / 2,
      y: (bounds.height - height) / 2,
      width: width,
      height: height
    )
  }

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

public final class LottieActivityIndicator: BaseLottieActivityIndicator {
  public init() {
    super.init(defaultSize: CGSize(width: 101, height: 101))
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

#endif
