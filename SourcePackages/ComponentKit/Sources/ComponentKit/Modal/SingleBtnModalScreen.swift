#if canImport(UIKit)

import UIKit

public class SingleBtnModalScreen: BaseModal {
  private let otherView = UIView()
  private let titleLabel = UILabel()
  public var mainTitle: String?
  public var btnAction: (() -> Void)?
  public var mainView: UIView?
  public var dismissAction: (() -> Void)?

  public var btnTitle: String? {
    didSet {
      if let btnTitle { btn.title = btnTitle }
    }
  }

  var btnEnable: Bool = true {
    didSet {
      btn.isEnabled = btnEnable
    }
  }

  private lazy var btn = Btn(
    isEnable: true,
    kind: .confirm,
    edges: NSDirectionalEdgeInsets(top: 7, leading: 40, bottom: 7, trailing: 40)
  )

  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(hex: 0x888888, alpha: 0.5)
    view.addSubview(contentView)
    view.addSubview(otherView)
    contentView.addSubview(titleLabel)
    contentView.addSubview(btn)
    titleLabel.text = mainTitle
    titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
    contentView.backgroundColor = .white
    contentView.layer.cornerRadius = 34
    contentView.layer.maskedCorners = [.topLeft, .topRight]

    contentView.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    otherView.translatesAutoresizingMaskIntoConstraints = false
    btn.translatesAutoresizingMaskIntoConstraints = false
    mainView?.translatesAutoresizingMaskIntoConstraints = false

    if let superview = contentView.superview, case .some = otherView.superview {
      NSLayoutConstraint.activate([
        contentView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
        contentView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
        contentView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
        contentView.heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: percentage),
        otherView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
        otherView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
        otherView.topAnchor.constraint(equalTo: superview.topAnchor),
        otherView.bottomAnchor.constraint(equalTo: contentView.topAnchor),
      ])
    }

    if let superview = titleLabel.superview {
      NSLayoutConstraint.activate([
        titleLabel.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
        titleLabel.topAnchor.constraint(equalTo: superview.topAnchor, constant: 38),
      ])
    }

    if let superview = btn.superview {
      NSLayoutConstraint.activate([
        btn.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
        btn.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -26),
      ])
    }
    
    btn.ex.click = btnAction

    if let mainView {
      contentView.addSubview(mainView)
      NSLayoutConstraint.activate([
        mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        mainView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
        mainView.bottomAnchor.constraint(equalTo: btn.topAnchor),
      ])
    }
    let outerTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOuterTap))
    otherView.addGestureRecognizer(outerTapGesture)
  }

  @objc func handleOuterTap() {
    dismissAction?()
  }
}

#endif
