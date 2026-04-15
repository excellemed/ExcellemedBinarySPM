#if canImport(UIKit)

import UIKit

open class OverCurrentContextModal: UIViewController {
  public var subscriptions = Set<AnyCancellable>()
  public let contentView = UIView()

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public init(percentage: CGFloat = 0.65) {
    self.percentage = percentage
    super.init(nibName: .none, bundle: .none)
    modalPresentationStyle = .overCurrentContext
    modalTransitionStyle = .crossDissolve
  }

  public var percentage: CGFloat

  override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    .portrait
  }

  deinit {
    debugPrint("\(String(describing: Self.self)) deinit")
  }

  open func slideIn() {
    contentView.frame.origin.y = view.frame.height
    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      options: .curveEaseInOut,
      animations: { [unowned self] in
        contentView.frame.origin.y = view.frame.height - (view.frame.height * percentage)
      },
    )
  }

  override open func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    slideIn()
  }

  open func slideOut() {
    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      options: .curveEaseInOut,
      animations: { [unowned self] in
        contentView.frame.origin.y = view.frame.height
      },
    )
  }

  override open func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    slideOut()
  }
}

#endif
