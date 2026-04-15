#if canImport(UIKit)

import UIKit

public final class AreaSelectorCell: UITableViewCell {
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }

  public let titleLabel = UILabel()
  private let checkIcon = UIImageView()

  public var isChoose: Bool = false {
    didSet {
      checkIcon.isHidden = !isChoose
    }
  }

  private func setup() {
    contentView.addSubview(titleLabel)
    contentView.addSubview(checkIcon)

    checkIcon.image = UIImage.Checked
    checkIcon.isHidden = true

    titleLabel.textColor = .exBlack
    titleLabel.font = .preferredFont(forTextStyle: .subheadline)

    checkIcon.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      checkIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
      checkIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 13),
      checkIcon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -13),
    ])

    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 13),
      titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -13),
    ])
  }
}

#endif
