#if canImport(UIKit)

import UIKit

open class NoBtnModalScreen: OverCurrentContextModal {
  public var mainView: UIView?
  private var otherView = UIView()
  public var backAction: (() -> Void)?

  override open func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(hex: 0x888888, alpha: 0.5)
    view.addSubview(otherView)
    view.addSubview(contentView)

    otherView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      otherView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      otherView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      otherView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      otherView.topAnchor.constraint(equalTo: view.topAnchor),
    ])

    contentView.backgroundColor = .white
    contentView.layer.cornerRadius = 34
    contentView.layer.maskedCorners = [.topLeft, .topRight]
    contentView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      contentView.heightAnchor.constraint(equalTo: contentView.superview!.heightAnchor, multiplier: percentage),
    ])

    if let main = mainView {
      contentView.addSubview(main)
      main.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        main.leadingAnchor.constraint(equalTo: main.superview!.leadingAnchor),
        main.trailingAnchor.constraint(equalTo: main.superview!.trailingAnchor),
        main.topAnchor.constraint(equalTo: main.superview!.topAnchor, constant: 22),
        main.bottomAnchor.constraint(equalTo: main.superview!.bottomAnchor),
      ])
    }

    let outerTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOuterTap))
    otherView.addGestureRecognizer(outerTapGesture)
  }

  @objc func handleOuterTap() {
    backAction?()
  }
}

#endif
