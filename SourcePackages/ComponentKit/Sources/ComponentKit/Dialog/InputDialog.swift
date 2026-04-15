#if canImport(UIKit)

import UIKit
import ComponentKit

public class InputDialogScreen: DialogController {
  private lazy var titleLabel = UILabel()
  lazy var textArea = UIView()
  public lazy var textField = TextField()
  lazy var icon = UIImageView(image: UIImage.EditCancel)
  private lazy var btnGroup = UIStackView()
  public var mainTitle: String?
  public var subtitle: String?
  public var cancel: (() -> Void)?
  public var confirm: (() -> Void)?
  public var delete: (() -> Void)?

  private lazy var confirmBtn = Btn(
    title: "确定", isEnable: true, kind: .confirm,
    edges: NSDirectionalEdgeInsets(top: 7, leading: 40, bottom: 7, trailing: 40)
  )
  private lazy var cancelBtn = Btn(
    title: "取消", isEnable: true, kind: .cancel,
    edges: NSDirectionalEdgeInsets(top: 7, leading: 40, bottom: 7, trailing: 40)
  )

  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(hex: 0x888888, alpha: 0.5)
    contentView.backgroundColor = .white
    contentView.layer.cornerRadius = 20
    contentView.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(contentView)

    if let superview = contentView.superview {
      NSLayoutConstraint.activate([
        contentView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 27),
        contentView.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -27),
        contentView.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
      ])
    }
    
    contentView.addSubview(titleLabel)
    contentView.addSubview(textArea)
    
    btnGroup.addArrangedSubview(cancelBtn)
    btnGroup.addArrangedSubview(confirmBtn)
    btnGroup.axis = .horizontal
    btnGroup.spacing = 20
    btnGroup.layoutMargins = UIEdgeInsets(top: 0, left: 37, bottom: 0, right: 37)
    btnGroup.isLayoutMarginsRelativeArrangement = true

    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.text = mainTitle
    titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
    titleLabel.numberOfLines = 0

    textArea.translatesAutoresizingMaskIntoConstraints = false
    textArea.addSubview(textField)
    textArea.addSubview(icon)

    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 45),
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25),
      textArea.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
      textArea.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
      textArea.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
      textArea.heightAnchor.constraint(equalToConstant: 42),
    ])
    
    contentView.addSubview(btnGroup)
    btnGroup.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      btnGroup.topAnchor.constraint(equalTo: textArea.bottomAnchor, constant: 20),
      btnGroup.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      btnGroup.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -45),
    ])

    textField.translatesAutoresizingMaskIntoConstraints = false
    icon.translatesAutoresizingMaskIntoConstraints = false
    if let superview = textField.superview {
      NSLayoutConstraint.activate([
        textField.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
        textField.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
        textField.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: 0.9),
      ])
    }
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(doAction))
    icon.addGestureRecognizer(tapGesture)
    icon.isUserInteractionEnabled = true
    if let superview = icon.superview {
      NSLayoutConstraint.activate([
        icon.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
        icon.widthAnchor.constraint(equalToConstant: 18),
        icon.heightAnchor.constraint(equalToConstant: 18),
        icon.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -20),
      ])
    }
    textField.attributedPlaceholder = NSAttributedString(
      string: subtitle ?? "",
      attributes: [
        .foregroundColor: UIColor.exDeepGray,
        .font: UIFont.preferredFont(forTextStyle: .subheadline),
      ]
    )
    textArea.layer.borderColor = UIColor.exDeepGray.cgColor
    textArea.layer.borderWidth = 2
    textArea.layer.cornerRadius = 21
    textArea.backgroundColor = .white

    cancelBtn.ex.click = cancel
    confirmBtn.ex.click = confirm
    textField.rx.text
      .map { ($0?.count ?? 0) == 0 }
      .bind(to: icon.rx.isHidden)
      .store(in: &subscriptions)
  }

  @objc private func doAction() {
    textField.text = ""
  }
}

#endif
