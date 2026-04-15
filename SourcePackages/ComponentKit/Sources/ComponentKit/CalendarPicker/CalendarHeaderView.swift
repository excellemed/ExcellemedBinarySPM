#if canImport(UIKit)

import UIKit

open class CalendarHeaderView: UIView {
  var style: CalendarPicker.Style = .Default {
    didSet {
      updateStyle()
    }
  }

  var monthLabel = UILabel()
  var leftArrow = LeftArrow()
  var rightArrow = LeftArrow(isReverse: true)
  var dayLabels: [UILabel] = []

  override public init(frame: CGRect) {
    super.init(frame: frame)
    monthLabel.backgroundColor = UIColor.clear
    
    monthLabel.translatesAutoresizingMaskIntoConstraints = false
    leftArrow.translatesAutoresizingMaskIntoConstraints = false
    rightArrow.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(leftArrow)
    addSubview(rightArrow)
    addSubview(monthLabel)
    for _ in 0 ..< 7 {
      let label = UILabel()
      label.backgroundColor = .clear
      label.translatesAutoresizingMaskIntoConstraints = false
      dayLabels.append(label)
      addSubview(label)
    }
  }

  public func updateStyle() {
    monthLabel.textAlignment = .center
    monthLabel.font = style.headerFont
    monthLabel.textColor = style.headerTextColor
    monthLabel.backgroundColor = style.headerBackgroundColor

    let formatter = DateFormatter()
    formatter.locale = style.locale
    formatter.timeZone = style.calendar.timeZone

    let start = style.firstWeekday == .sunday ? 0 : 1
    var i = 0

    for index in start ..< (start + 7) {
      let label = dayLabels[i]
      label.font = style.weekdaysFont

      label.text =
        style.weekDayTransform == .capitalized
        ? formatter.veryShortWeekdaySymbols[index % 7].capitalized
        : formatter.veryShortWeekdaySymbols[index % 7].uppercased()
      label.textColor = style.weekdaysTextColor
      label.textAlignment = .center
      i += 1
    }

    backgroundColor = style.weekdaysBackgroundColor
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override open func layoutSubviews() {
    super.layoutSubviews()
    setupConstraints()
  }

  private func setupConstraints() {
    if let superview = monthLabel.superview {
      NSLayoutConstraint.activate([
        monthLabel.topAnchor.constraint(equalTo: superview.topAnchor, constant: style.headerTopMargin),
        monthLabel.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
        monthLabel.heightAnchor.constraint(
          equalToConstant: bounds.size.height
            - style.headerTopMargin
            - style.weekdaysHeight
            - style.weekdaysBottomMargin
            - style.weekdaysTopMargin
        ),
      ])
    }

    if let superview = leftArrow.superview, case .some = rightArrow.superview {
      NSLayoutConstraint.activate([
        leftArrow.trailingAnchor.constraint(equalTo: monthLabel.leadingAnchor, constant: -10),
        leftArrow.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
        leftArrow.heightAnchor.constraint(equalToConstant: 16),
        rightArrow.leadingAnchor.constraint(equalTo: monthLabel.trailingAnchor, constant: 10),
        rightArrow.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
        rightArrow.widthAnchor.constraint(equalToConstant: 16),
        rightArrow.heightAnchor.constraint(equalToConstant: 16),
      ])
    }

    let w = bounds.width / 7
    for (index, label) in dayLabels.enumerated() {
      if let superview = label.superview {
        NSLayoutConstraint.activate([
          label.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: style.weekdaysTopMargin),
          label.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: CGFloat(index) * w),
          label.widthAnchor.constraint(equalToConstant: w),
          label.heightAnchor.constraint(equalToConstant: style.weekdaysHeight),
        ])
      }
    }
  }
}

#endif
