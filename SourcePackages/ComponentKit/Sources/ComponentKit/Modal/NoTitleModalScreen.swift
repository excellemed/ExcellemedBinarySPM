#if canImport(UIKit)

import UIKit

public class NoTitleModalScreen: BaseModal {
  private lazy var btnGroup = UIStackView()
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

  private func setupContent() {
    view.addSubview(contentView)
    view.backgroundColor = UIColor(hex: 0x888888, alpha: 0.5)
    contentView.addSubview(btnGroup)

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

    leftBtn.translatesAutoresizingMaskIntoConstraints = false
    rightBtn.translatesAutoresizingMaskIntoConstraints = false
    btnGroup.axis = .horizontal
    btnGroup.spacing = 20
    if let leftBtnAction, let leftBtnTitle {
      btnGroup.addArrangedSubview(leftBtn)
      leftBtn.ex.click = leftBtnAction
    }
    btnGroup.addArrangedSubview(rightBtn)
    btnGroup.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      btnGroup.leadingAnchor.constraint(equalTo: btnGroup.superview!.leadingAnchor, constant: 64),
      btnGroup.trailingAnchor.constraint(equalTo: btnGroup.superview!.trailingAnchor, constant: -64),
      btnGroup.bottomAnchor.constraint(equalTo: btnGroup.superview!.safeAreaLayoutGuide.bottomAnchor, constant: -26),
    ])
    rightBtn.ex.click = rightBtnAction

    if let main = mainView {
      contentView.addSubview(main)
      main.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        main.leadingAnchor.constraint(equalTo: main.superview!.leadingAnchor),
        main.trailingAnchor.constraint(equalTo: main.superview!.trailingAnchor),
        main.topAnchor.constraint(equalTo: main.superview!.topAnchor, constant: 30),
        main.bottomAnchor.constraint(equalTo: btnGroup.topAnchor),
      ])
    }
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    setupContent()
  }
}

#endif
