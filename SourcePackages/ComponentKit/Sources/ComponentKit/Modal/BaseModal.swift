#if canImport(UIKit)

import UIKit

open class BaseModal: UIViewController {
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public var subscriptions = Set<AnyCancellable>()
  public var percentage: CGFloat
  let contentView: UIView

  public init(percentage: CGFloat = 0.65) {
    self.percentage = percentage
    self.contentView = UIView()
    super.init(nibName: .none, bundle: .none)
    modalPresentationStyle = .custom
    modalTransitionStyle = .crossDissolve
  }

  override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    .portrait
  }

  deinit {
    debugPrint("\(String(describing: Self.self)) deinit")
  }
}

extension BaseModal {
  private func slideIn() {
    let animation = CABasicAnimation(keyPath: "position.y")
    animation.fromValue = view.frame.height + contentView.frame.height / 2
    animation.toValue = view.frame.height - (view.frame.height * percentage) / 2
    animation.duration = 0.3
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    contentView.layer.add(animation, forKey: "slideIn")
  }

  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    slideIn()
  }

  private func slideOut() {
    let animation = CABasicAnimation(keyPath: "position.y")
    animation.fromValue = view.frame.height - (view.frame.height * percentage) / 2
    animation.toValue = view.frame.height + contentView.frame.height / 2
    animation.duration = 0.3
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    contentView.layer.add(animation, forKey: "slideOut")
  }

  override public func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    slideOut()
  }
}

#endif
