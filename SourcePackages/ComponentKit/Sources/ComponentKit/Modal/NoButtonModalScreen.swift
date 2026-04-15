#if canImport(UIKit)

import UIKit

open class NoButtonModalScreen: OverCurrentContextModal {
  public var mainView: UIView?
  private let otherView = UIView()
  public var backAction: (() -> Void) = {
    print("外部被点击了")
  }

  override open func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(hex: 0x888888, alpha: 0.5)
    view.addSubview(contentView)
    view.addSubview(otherView)

    contentView.layer.cornerRadius = 34
    contentView.layer.maskedCorners = [.topLeft, .topRight]
    contentView.backgroundColor = .white

    contentView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      contentView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: percentage),
    ])

    otherView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      otherView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      otherView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      otherView.topAnchor.constraint(equalTo: view.topAnchor),
      otherView.bottomAnchor.constraint(equalTo: contentView.topAnchor),
    ])

    if let main = mainView {
      contentView.addSubview(main)
      main.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        main.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        main.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        main.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        main.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
      ])
    }
    let outerTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOuterTap))
    otherView.addGestureRecognizer(outerTapGesture)
  }

  @objc func handleOuterTap() {
    backAction()
  }
}

open class NormalNoButtonModalScreen: NoBtnModalScreen {
  override public init(percentage: CGFloat) {
    super.init(percentage: percentage)
    modalPresentationStyle = .custom
  }
}

#endif
