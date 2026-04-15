#if canImport(UIKit)

import UIKit
import enum ToolKit.IconFont

public class SingleCloseDialogScreen: DialogController {
  private lazy var headView = UIView()
  private lazy var subtitleLabel = UILabel()
  private let subtitleLabelContainer = UIView()
  private lazy var titleLabel = UILabel()
  private let icon = UIImageView()

  public var text: NSAttributedString? {
    didSet {
      subtitleLabel.attributedText = text
    }
  }

  public var titleText: String? {
    didSet {
      titleLabel.text = titleText
    }
  }

  public var image: UIImage? {
    didSet {
      icon.image = image
    }
  }

  public var cancel: (() -> Void)?

  private lazy var cancelBtn = UIButton()

  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(hex: 0x888888, alpha: 0.5)
    view.addSubview(contentView)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.backgroundColor = .white
    contentView.layer.cornerRadius = 20
    
    if let superview = contentView.superview {
      NSLayoutConstraint.activate([
        contentView.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
        contentView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 27),
        contentView.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -27),
      ])
    }
    
    contentView.addSubview(headView)
    if let superview = headView.superview {
      NSLayoutConstraint.activate([
        headView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
        headView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
        headView.topAnchor.constraint(equalTo: superview.topAnchor, constant: 20),
        headView.heightAnchor.constraint(equalToConstant: 40),
      ])
    }
    headView.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    icon.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabelContainer.translatesAutoresizingMaskIntoConstraints = false
    headView.addSubview(titleLabel)
    headView.addSubview(icon)

    if let superview = titleLabel.superview, case .some = icon.superview {
      NSLayoutConstraint.activate([
        titleLabel.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
        titleLabel.topAnchor.constraint(equalTo: superview.topAnchor),
        titleLabel.bottomAnchor.constraint(equalTo: superview.bottomAnchor),

        icon.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
        icon.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
        icon.widthAnchor.constraint(equalToConstant: 33),
        icon.heightAnchor.constraint(equalToConstant: 30),
      ])
    }
    contentView.addSubview(subtitleLabelContainer)
    subtitleLabelContainer.addSubview(subtitleLabel)
    if let superview = subtitleLabelContainer.superview, let subtitleLabelSuper = subtitleLabel.superview {
      NSLayoutConstraint.activate([
        subtitleLabel.leadingAnchor.constraint(equalTo: subtitleLabelSuper.leadingAnchor, constant: 37),
        subtitleLabel.trailingAnchor.constraint(equalTo: subtitleLabelSuper.trailingAnchor, constant: -37),
        subtitleLabel.topAnchor.constraint(equalTo: subtitleLabelSuper.topAnchor),
        subtitleLabel.bottomAnchor.constraint(equalTo: subtitleLabelSuper.bottomAnchor),

        subtitleLabelContainer.topAnchor.constraint(equalTo: headView.bottomAnchor, constant: 20),
        subtitleLabelContainer.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -70),
        subtitleLabelContainer.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
        subtitleLabelContainer.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
      ])
    }
    titleLabel.text = titleText
    titleLabel.font = .preferredFont(forTextStyle: .title3)
    titleLabel.textColor = .exBlack
    subtitleLabel.attributedText = text
    subtitleLabel.font = .preferredFont(forTextStyle: .headline)
    subtitleLabel.numberOfLines = 0
    cancelBtn.setImage(
      UIImage(from: IconFont.close, textColor: .white, backgroundColor: .clear, size: CGSize(width: 20, height: 20)),
      for: .normal
    )
    view.addSubview(cancelBtn)
    cancelBtn.translatesAutoresizingMaskIntoConstraints = false
    cancelBtn.layer.borderColor = UIColor.white.cgColor
    cancelBtn.layer.borderWidth = 2
    cancelBtn.layer.cornerRadius = 16
    if let superview = cancelBtn.superview {
      NSLayoutConstraint.activate([
        cancelBtn.widthAnchor.constraint(equalToConstant: 32),
        cancelBtn.heightAnchor.constraint(equalToConstant: 32),
        cancelBtn.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 20),
        cancelBtn.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
      ])
    }
    cancelBtn.ex.click = cancel
  }
}

#endif
