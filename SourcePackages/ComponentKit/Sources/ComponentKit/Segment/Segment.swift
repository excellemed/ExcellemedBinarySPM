import UIKit

public final class SegmentItem: UIButton {
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public init(with item: Segment.Item) {
    super.init(frame: .zero)
    backgroundColor = .clear
    setup(item)
    setupBadge()
  }

  public var normalAttribute: [NSAttributedString.Key: Any]?
  public var activeAttribute: [NSAttributedString.Key: Any]?

  public var normalColor: UIColor?
  public var activeColor: UIColor?

  public var normalIcon: UIImage?
  public var activeIcon: UIImage?
  
  private var badge: CALayer?
  
  public var showBadge: Bool = false {
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

  public override var isSelected: Bool {
    didSet {
      setNeedsUpdateConfiguration()
    }
  }

  public func setup(_ item: Segment.Item) {
    let textStyle = item.text
    let imageStyle = item.icon
    let text = textStyle.text
    let attribute0 = textStyle.normalAttributes
    let attribute1 = textStyle.activeAttributes

    let image = imageStyle?.image
    let color0 = imageStyle?.normalColor
    let color1 = imageStyle?.activeColor

    normalAttribute = attribute0
    activeAttribute = attribute1
    normalColor = color0
    activeColor = color1

    var cfg = UIButton.Configuration.plain()
    cfg.title = text
    cfg.baseBackgroundColor = .clear
    cfg.baseForegroundColor = normalAttribute?[.foregroundColor] as? UIColor ?? UIColor.exLightGray
    cfg.imagePadding = 6
    if let image {
      let icon = MutableColorIcon(image)
      icon.backgroundColor = normalColor
      cfg.image = icon.ex.snapshot
      normalIcon = cfg.image
      icon.backgroundColor = activeColor
      activeIcon = icon.ex.snapshot
    }
    configuration = cfg

    configurationUpdateHandler = { [unowned self] in
      if var config = $0.configuration {
        if $0.isSelected {
          if let activeIcon {
            config.image = activeIcon
          }
          config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { [unowned self] container in
            var outgoing = container
            outgoing.font = activeAttribute?[.font] as? UIFont ?? UIFont.preferredFont(forTextStyle: .footnote)
            outgoing.foregroundColor = activeAttribute?[.foregroundColor] as? UIColor ?? .exBlack
            return outgoing
          }
        } else {
          if let normalIcon {
            config.image = normalIcon
          }
          config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { [unowned self] container in
            var outgoing = container
            outgoing.font = normalAttribute?[.font] as? UIFont ?? UIFont.preferredFont(forTextStyle: .footnote)
            outgoing.foregroundColor = normalAttribute?[.foregroundColor] as? UIColor ?? .exBlack
            return outgoing
          }
        }
        $0.configuration = config
      }
    }
  }
  
  private func setupBadge() {
    let subLayer = CALayer()
    subLayer.backgroundColor = UIColor.exRed.cgColor
    subLayer.cornerRadius = 4
    subLayer.shadowColor = UIColor.exRed.cgColor
    subLayer.shadowOpacity = 0.5
    subLayer.shadowOffset = CGSize(width: 1, height: 1)
    subLayer.shadowPath = UIBezierPath(rect: layer.bounds).cgPath
    self.badge = subLayer
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    if let badge {
      let x = bounds.width * 0.8
      let y = bounds.height * 0.2
      badge.frame = CGRectMake(x, y, 8, 8)
    }
  }
}

public final class Segment: UIControl {
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
  
  public struct Item {
    public struct Text {
      public var text: String
      public var normalAttributes: Attribute?
      public var activeAttributes: Attribute?

      public init(_ text: String, normalAttributes: Attribute? = .none, activeAttributes: Attribute? = .none) {
        self.text = text
        self.normalAttributes = normalAttributes
        self.activeAttributes = activeAttributes
      }
    }

    public struct Icon {
      public var image: UIImage?
      public var normalColor: UIColor?
      public var activeColor: UIColor?
      public init(_ image: UIImage? = .none, _ normalColor: UIColor? = .none, _ activeColor: UIColor? = .none) {
        self.image = image
        self.normalColor = normalColor
        self.activeColor = activeColor
      }
    }
    public var text: Text
    public var icon: Icon?
    
    public init(_ text: Text, icon: Icon? = .none) {
      self.text = text
      self.icon = icon
    }
  }

  public init(
    titles: [Item]? = .none,
    index: Int? = .none
  ) {
    super.init(frame: .zero)
    self.titles = titles
    if let index {
      self.i = index
    }
    setup()
  }

  private var _titles: [Item]?

  public var titles: [Item]? {
    get { _titles }

    set {
      let isSameCount = newValue?.count == _titles?.count
      _titles = newValue
      updateSegmentItems()
      if !isSameCount {
        i = 0
      }
    }
  }

  public let indicator = UIView()

  public var showIndicator: Bool = false {
    willSet {
      if showIndicator != newValue {
        indicator.isHidden = !newValue
        didSelected()
      }
    }
  }

  public let contentView = UIStackView()
  public var items: [SegmentItem] = []
  public var indicatorConstraint: NSLayoutConstraint?

  private var _i: Int?
  public var i: Int {
    set {
      if newValue != _i {
        _i = newValue
        didSelected()
      }
    }
    get { _i ?? 0 }
  }
}

extension Segment {
  private func updateSegmentItems() {
    for it in items {
      it.removeFromSuperview()
    }
    items.removeAll()
    if let titles {
      for (i, item) in titles.enumerated() {
        let segmentItem = SegmentItem(with: item)
        items.append(segmentItem)
        contentView.addArrangedSubview(segmentItem)
        segmentItem.tag = i
        segmentItem.addTarget(self, action: #selector(tap), for: .touchUpInside)
      }
    }

    for item in items {
      item.topAnchor.constraint(equalTo: item.superview!.topAnchor).isActive = true
      item.bottomAnchor.constraint(equalTo: item.superview!.bottomAnchor).isActive = true
    }
  }

  private func setup() {
    addSubview(contentView)
    addSubview(indicator)
    indicator.isHidden = !showIndicator
    contentView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: topAnchor),
      contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

    contentView.axis = .horizontal
    contentView.alignment = .center
    contentView.distribution = .fillEqually
    contentView.spacing = 0

    updateSegmentItems()
    indicator.backgroundColor = .exBlack
    indicator.layer.cornerRadius = 1

    indicatorConstraint = indicator.centerXAnchor.constraint(equalTo: leadingAnchor)
    indicator.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      indicator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
      indicator.heightAnchor.constraint(equalToConstant: 2)
    ])
    if let segmentItem = items.first {
      indicator.widthAnchor.constraint(equalTo: segmentItem.widthAnchor, multiplier: 0.5).isActive = true
    }
    didSelected()
  }

  @objc private func tap(_ sender: SegmentItem) {
    i = sender.tag
  }

  private func didSelected() {
    for (index, item) in items.enumerated() {
      if i == index {
        item.isSelected = true
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
              sendActions(for: .valueChanged)
            }
          )
        }
      } else {
        item.isSelected = false
      }
    }
  }
}

extension Reactive where Base: Segment {
  @MainActor
  public var valueChanged: Observable<Int> {
    controlEvent(for: .valueChanged)
      .map { base.i }
      .eraseToAnyPublisher()
  }
}
