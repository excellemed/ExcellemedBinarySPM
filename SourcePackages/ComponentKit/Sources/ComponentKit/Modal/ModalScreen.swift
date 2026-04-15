#if canImport(UIKit)

import UIKit

public class ModalScreen: BaseModal {
  private let otherView = UIView()
  private lazy var titleLabel = UILabel()
  private lazy var btnGroup = UIStackView()
  public var mainTitle: String?
  public var leftBtnAction: (() -> Void)?
  public var rightBtnAction: (() -> Void)?
  public var mainView: UIView?

  public var leftBtnTitle: String? {
    didSet {
      if let t = leftBtnTitle {
        leftBtn.title = t
      }
    }
  }

  public var rightBtnTitle: String? {
    didSet {
      if let t = rightBtnTitle {
        rightBtn.title = t
      }
    }
  }
  public var rightBtnEnable: Bool = true {
    didSet {
      rightBtn.isEnabled = rightBtnEnable
    }
  }

  private lazy var rightBtn = Btn(
    isEnable: true,
    kind: .confirm,
    edges: NSDirectionalEdgeInsets(top: 7, leading: 0, bottom: 7, trailing: 0)
  )
  private lazy var leftBtn = Btn(
    isEnable: true,
    kind: .cancel,
    edges: NSDirectionalEdgeInsets(top: 7, leading: 0, bottom: 7, trailing: 0)
  )

  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(hex: 0x888888, alpha: 0.5)
    view.addSubview(contentView)
    view.addSubview(otherView)
    contentView.addSubview(titleLabel)
    contentView.addSubview(btnGroup)
    titleLabel.text = mainTitle
    titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
    contentView.backgroundColor = .white
    contentView.layer.cornerRadius = 34
    contentView.layer.maskedCorners = [.topLeft, .topRight]

    contentView.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    otherView.translatesAutoresizingMaskIntoConstraints = false
    btnGroup.translatesAutoresizingMaskIntoConstraints = false
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

    btnGroup.axis = .horizontal
    btnGroup.spacing = 20
    btnGroup.addArrangedSubview(leftBtn)
    btnGroup.addArrangedSubview(rightBtn)
    if let superview = btnGroup.superview {
      NSLayoutConstraint.activate([
        btnGroup.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 64),
        btnGroup.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -64),
        btnGroup.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -26),
      ])
    }

    leftBtn.ex.click = leftBtnAction
    rightBtn.ex.click = rightBtnAction

    if let mainView {
      contentView.addSubview(mainView)
      NSLayoutConstraint.activate([
        mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        mainView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
        mainView.bottomAnchor.constraint(equalTo: btnGroup.topAnchor),
      ])
    }
    let outerTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOuterTap))
    otherView.addGestureRecognizer(outerTapGesture)
  }

  @objc func handleOuterTap() {
    leftBtnAction?()
  }
}

#endif
