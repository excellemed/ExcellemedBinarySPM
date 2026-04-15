#if canImport(UIKit)

import UIKit

open class CalendarDayCell: UICollectionViewCell {
  var style: CalendarPicker.Style = .Default

  var eventsCount = 0 {
    didSet {
      dotsView.isHidden = (eventsCount == 0)
      setNeedsLayout()
    }
  }

  var day: Int? {
    get {
      guard let value = textLabel.text else { return nil }
      return Int(value)
    }

    set {
      guard let value = newValue else {
        textLabel.text = nil
        return
      }
      textLabel.text = String(value)
    }
  }

  func updateTextColor() {
    if isOutOfRange {
      textLabel.textColor = style.cellColorOutOfRange
    } else if isPicked {
      textLabel.textColor = style.cellSelectedTextColor
    } else if isToday {
      textLabel.textColor = style.cellTextColorToday
    } else if isAdjacent {
      textLabel.textColor = style.cellColorAdjacent
    } else if isWeekend {
      textLabel.textColor = style.cellTextColorWeekend
    } else {
      textLabel.textColor = style.cellTextColorDefault
    }
  }

  var isToday: Bool = false {
    didSet {
      switch isToday {
      case true:
        bgView.backgroundColor = style.cellColorToday
      case false:
        bgView.backgroundColor = style.cellColorDefault
      }

      updateTextColor()
    }
  }

  private var _isOutOfRange: Bool = false
  var isOutOfRange: Bool {
    get { _isOutOfRange }
    set {
      guard _isOutOfRange != newValue else { return }
      _isOutOfRange = newValue
      updateTextColor()
    }
  }

  var isAdjacent: Bool = false {
    didSet {
      updateTextColor()
    }
  }

  var isWeekend: Bool = false {
    didSet {
      updateTextColor()
    }
  }

  open var isPicked: Bool = false {
    didSet {
      switch isPicked {
      case true:
        bgView.layer.borderColor = style.cellSelectedBorderColor.cgColor
        bgView.layer.borderWidth = style.cellSelectedBorderWidth
        bgView.backgroundColor = style.cellSelectedColor
      case false:
        bgView.layer.borderColor = style.cellBorderColor.cgColor
        bgView.layer.borderWidth = style.cellBorderWidth
        if isToday {
          bgView.backgroundColor = style.cellColorToday
        } else {
          bgView.backgroundColor = style.cellColorDefault
        }
      }

      updateTextColor()
    }
  }

  public func clearStyles() {
    bgView.layer.borderColor = style.cellBorderColor.cgColor
    bgView.layer.borderWidth = style.cellBorderWidth
    bgView.backgroundColor = style.cellColorDefault
    textLabel.textColor = style.cellTextColorDefault
    eventsCount = 0
  }

  let textLabel = UILabel()
  let dotsView = UIView()
  let bgView = UIView()

  override init(frame: CGRect) {
    textLabel.textAlignment = NSTextAlignment.center
    dotsView.backgroundColor = style.cellEventColor
    textLabel.font = style.cellFont
    super.init(frame: frame)
    contentView.addSubview(bgView)
    contentView.addSubview(textLabel)
    contentView.addSubview(dotsView)
    bgView.translatesAutoresizingMaskIntoConstraints = false
    textLabel.translatesAutoresizingMaskIntoConstraints = false

    if let superview = bgView.superview, case .some = textLabel.superview {
      NSLayoutConstraint.activate([
        bgView.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
        bgView.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
        bgView.widthAnchor.constraint(equalToConstant: 28),
        bgView.heightAnchor.constraint(equalToConstant: 28),
        textLabel.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
        textLabel.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
      ])
    }
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override open func layoutSubviews() {
    super.layoutSubviews()
    var elementsFrame = contentView.bounds.insetBy(dx: 3.0, dy: 3.0)

    if style.cellShape.isRound {
      let smallestSide = min(elementsFrame.width, elementsFrame.height)
      elementsFrame = elementsFrame.insetBy(
        dx: (elementsFrame.width - smallestSide) / 2.0,
        dy: (elementsFrame.height - smallestSide) / 2.0
      )
    }

    //    bgView.frame = elementsFrame
    //    textLabel.frame = elementsFrame

    let size = contentView.bounds.height * 0.08
    dotsView.frame = CGRect(x: 0, y: 0, width: size, height: size)
    dotsView.center = CGPoint(x: textLabel.center.x, y: contentView.bounds.height - (2.5 * size))
    dotsView.layer.cornerRadius = size * 0.5

    switch style.cellShape {
    case .square:
      bgView.layer.cornerRadius = 0.0
    case .round:
      //      bgView.layer.cornerRadius = elementsFrame.width * 0.5
      bgView.layer.cornerRadius = 28 * 0.5
    case let .bevel(radius):
      bgView.layer.cornerRadius = radius
    }
  }
}

#endif
