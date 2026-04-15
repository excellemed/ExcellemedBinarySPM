import UIKit

final class BadgesSegmentItem: UIButton {
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(with subview: UIView) {
    self.subview = subview
    super.init(frame: .zero)
    addSubview(subview)
    backgroundColor = .clear

    let subLayer = CALayer()
    subLayer.backgroundColor = UIColor.exRed.cgColor
    subLayer.cornerRadius = 4
    subLayer.shadowColor = UIColor.exRed.cgColor
    subLayer.shadowOpacity = 0.5
    subLayer.shadowOffset = CGSize(width: 1, height: 1)
    subLayer.shadowPath = UIBezierPath(rect: layer.bounds).cgPath
    self.badge = subLayer

    subview.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      subview.centerXAnchor.constraint(equalTo: centerXAnchor),
      subview.topAnchor.constraint(equalTo: topAnchor),
      subview.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    if let badge {
      let x = bounds.width * 0.8
      let y = bounds.height * 0.2
      badge.frame = CGRect(x: x, y: y, width: 8, height: 8)
    }
  }

  var subview: UIView
  private var badge: CALayer?

  var showBadge: Bool = false {
    didSet {
      if let badge {
        if showBadge {
          layer.addSublayer(badge)
          setNeedsLayout()
        } else {
          badge.removeFromSuperlayer()
        }
      }
    }
  }
}

public final class BadgesSegment: UIControl {
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public typealias Attribute = [NSAttributedString.Key: Any]

  public var badges: [Int?: Bool] = [:] {
    didSet {
      for (k, v) in badges {
        if let k {
          items[at: k]?.showBadge = v
        }
      }
    }
  }

  public init(
    titles: [String]? = .none,
    index: Int? = .none,
    attributes: (Attribute, Attribute)? = .none
  ) {
    super.init(frame: .zero)
    self.attributes =
      attributes ?? (
        [.font: UIFont.preferredFont(forTextStyle: .headline), .foregroundColor: UIColor.exBlack],
        [.font: UIFont.preferredFont(forTextStyle: .headline), .foregroundColor: UIColor.exLightGray]
      )
    self.titles = titles
    self.i = index ?? 0
    setup()
  }

  private var _titles: [String]?

  public var titles: [String]? {
    get { _titles }

    set {
      let isSameCount = newValue?.count == _titles?.count
      _titles = newValue
      if !isSameCount {
        prevI = 0
        i = 0
      }
      updateBadgesSegmentItems()
    }
  }

  public var attributes: ([NSAttributedString.Key: Any], [NSAttributedString.Key: Any])?
  private let indicator = UIView()

  public var showIndicator: Bool = false {
    willSet {
      if showIndicator != newValue {
        indicator.isHidden = !newValue
        didSelected()
      }
    }
  }

  private let contentView = UIStackView()
  private var items: [BadgesSegmentItem] = []
  private var prevI: Int = 0
  private var indicatorConstraint: NSLayoutConstraint?

  var i: Int = 0 {
    didSet {
      if i != prevI {
        didSelected()
      }
    }
  }
}

extension BadgesSegment {
  private func updateBadgesSegmentItems() {
    for it in items {
      it.removeFromSuperview()
    }
    items.removeAll()
    if let titles {
      for (i, title) in titles.enumerated() {
        let label = UILabel()
        label.textAlignment = .center
        label.text = title
        let item = BadgesSegmentItem(with: label)
        item.translatesAutoresizingMaskIntoConstraints = false
        items.append(item)
        contentView.addArrangedSubview(item)
        item.tag = i
        item.addTarget(self, action: #selector(tap), for: .touchUpInside)
        badges[i] = false
      }
    }

    for item in items {
      item.topAnchor.constraint(equalTo: item.superview!.topAnchor).isActive = true
      item.bottomAnchor.constraint(equalTo: item.superview!.bottomAnchor).isActive = true
    }

    for (k, v) in badges {
      if let k {
        items[at: k]?.showBadge = v
      }
    }
  }

  private func setup() {
    addSubview(contentView)
    addSubview(indicator)
    indicator.isHidden = !showIndicator

    contentView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
      contentView.topAnchor.constraint(equalTo: topAnchor),
      contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])

    contentView.axis = .horizontal
    contentView.alignment = .center
    contentView.distribution = .fillEqually
    contentView.spacing = 0

    updateBadgesSegmentItems()
    indicator.backgroundColor = .exBlack
    indicator.layer.cornerRadius = 1

    indicatorConstraint = indicator.centerXAnchor.constraint(equalTo: leadingAnchor)
    indicator.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      indicatorConstraint!,
      indicator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
      indicator.heightAnchor.constraint(equalToConstant: 2),
    ])
    if let label = items.first {
      indicator.widthAnchor.constraint(equalTo: label.subview.widthAnchor, multiplier: 0.5).isActive = true
    }
    didSelected()
  }

  @objc private func tap(_ sender: BadgesSegmentItem) {
    i = sender.tag
  }

  private func didSelected() {
    for item in items {
      if let label = item.subview as? UILabel, let text = label.text, let attributes {
        label.attributedText = NSAttributedString(string: text, attributes: attributes.1)
      }
    }

    if let item = items[at: Int(i)],
      let label = item.subview as? UILabel,
      let text = label.text, let attributes
    {
      label.attributedText = NSAttributedString(string: text, attributes: attributes.0)
      if let container = indicator.superview {
        indicatorConstraint?.isActive = false
        indicatorConstraint = indicator.centerXAnchor.constraint(equalTo: item.centerXAnchor)
        indicatorConstraint?.isActive = true

        UIView.animate(
          withDuration: 0.3,
          delay: 0,
          usingSpringWithDamping: 0.66,
          initialSpringVelocity: 3,
          options: .curveEaseInOut,
          animations: { [unowned self] in
            container.layoutIfNeeded()
            prevI = i
            sendActions(for: .valueChanged)
          }
        )
      }
    }
  }
}

extension Reactive where Base: BadgesSegment {
  @MainActor
  public var onValueChanged: Observable<Int> {
    controlEvent(for: .valueChanged)
      .map { base.i }
      .eraseToAnyPublisher()
  }
}
