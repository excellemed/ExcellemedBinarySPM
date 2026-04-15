#if canImport(UIKit)

import ComponentKit
import UIKit

public final class TopIndicatorSegment: UIControl {
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  typealias Attribute = [NSAttributedString.Key: Any]

  public init(
    titles: [Segment.Item]? = .none,
    index: Int? = .none
  ) {
    super.init(frame: .zero)
    self.titles = titles
    if let index {
      self.i = index
    }
    setup()
  }

  private var _titles: [Segment.Item]?

  var titles: [Segment.Item]? {
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

  private let indicator = UIView()

  public var indicatorBg: UIColor = .exBlack {
    didSet {
      indicator.backgroundColor = indicatorBg
    }
  }

  public var showIndicator: Bool = false {
    willSet {
      if showIndicator != newValue {
        indicator.isHidden = !newValue
        didSelected()
      }
    }
  }

  private let contentView = UIStackView()
  private var items: [SegmentItem] = []
  private var indicatorConstraint: NSLayoutConstraint?

  private var _i: Int?
  public var i: Int {
    get { _i ?? 0 }
    set {
      if newValue != _i {
        _i = newValue
        didSelected()
      }
    }
  }
}

extension TopIndicatorSegment {
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
      contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
      contentView.topAnchor.constraint(equalTo: topAnchor),
      contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
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
      indicator.topAnchor.constraint(equalTo: topAnchor, constant: 2),
      indicator.heightAnchor.constraint(equalToConstant: 2)
    ])
    if let segmentItem = items.first {
      indicator.widthAnchor.constraint(equalTo: segmentItem.widthAnchor, multiplier: 0.5).isActive =
        true
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

extension Reactive where Base: TopIndicatorSegment {
  public var valueChanged: Observable<Int> {
    controlEvent(for: .valueChanged).map { base.i }.eraseToAnyPublisher()
  }
}

#endif
