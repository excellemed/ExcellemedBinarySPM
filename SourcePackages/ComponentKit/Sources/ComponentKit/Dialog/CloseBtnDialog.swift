#if canImport(UIKit)

import UIKit
import enum ToolKit.IconFont

public class CloseBtnDialog: DialogController {
  private lazy var headView = UIView()
  private lazy var subtitleLabel = UILabel()
  private lazy var titleLabel = UILabel()
  public var text: NSAttributedString? {
    didSet {
      subtitleLabel.attributedText = text
    }
  }

  public var cancel: (() -> Void)?
  public var add: (() -> Void)?
  public var set: (() -> Void)?
  public var putOff: (() -> Void)?

  private lazy var cancelBtn = UIButton()
  private lazy var putOffBtn = UIButton()
  private lazy var setBtn = Btn(title: "儿童个性化预警设置", isEnable: true, kind: .red)

  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(hex: 0x888888, alpha: 0.5)
    view.addSubview(contentView)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.backgroundColor = .white
    contentView.layer.cornerRadius = 20
    if let superview = contentView.superview {
      NSLayoutConstraint.activate([
        contentView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 27),
        contentView.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -27),
        contentView.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
      ])
    }
    contentView.addSubview(setBtn)
    titleLabel.text = "儿童预警提醒"
    titleLabel.font = .preferredFont(forTextStyle: .title3)
    titleLabel.textColor = .exBlack
    subtitleLabel.attributedText = text
    subtitleLabel.font = .preferredFont(forTextStyle: .headline)
    subtitleLabel.numberOfLines = 0
    setBtn.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      setBtn.widthAnchor.constraint(equalToConstant: 191),
      setBtn.heightAnchor.constraint(equalToConstant: 36),
    ])
    putOffBtn.setTitle("15分钟内不再提醒", for: .normal)
    putOffBtn.titleLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
    putOffBtn.setTitleColor(UIColor.exDeepGray, for: .normal)

    cancelBtn.setImage(
      UIImage(from: IconFont.close, textColor: .white, backgroundColor: .clear, size: CGSize(width: 20, height: 20)),
      for: .normal
    )
    cancelBtn.ex.click = cancel
    setBtn.ex.click = set
    putOffBtn.ex.click = putOff
  }

  private func slideIn() {
    let animation = CABasicAnimation(keyPath: "position.y")
    animation.fromValue = view.frame.height + view.center.y
    animation.toValue = view.frame.height - view.center.y
    animation.duration = 0.3
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

    contentView.layer.add(animation, forKey: "slideIn")
    cancelBtn.layer.add(animation, forKey: "slideIn")
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    slideIn()
  }

  private func slideOut() {
    let animation = CABasicAnimation(keyPath: "position.y")
    animation.fromValue = view.frame.height - view.center.y
    animation.toValue = view.frame.height + view.center.y
    animation.duration = 0.3
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

    contentView.layer.add(animation, forKey: "slideOut")
    cancelBtn.layer.add(animation, forKey: "slideOut")
  }

  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    slideOut()
  }
}

#endif
