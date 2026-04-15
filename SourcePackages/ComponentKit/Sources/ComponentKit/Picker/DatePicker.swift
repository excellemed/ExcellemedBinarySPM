#if canImport(UIKit)

import UIKit

public final class DatePicker: PickerView {
  public var minYear: Int? {
    didSet {
      if minYear == maxYear, maxYear == Date().ex.year {
        maxMonth = Date().ex.month
      } else {
        maxMonth = 12
      }
    }
  }

  public var maxYear: Int? {
    didSet {
      if maxYear == Date().ex.year {
        maxMonth = Date().ex.month
      } else {
        maxMonth = 12
      }
    }
  }

  private var maxMonth: Int? {
    didSet {
      if maxMonth == current[1] {
        maxDay = Date().ex.day
      } else {
        maxDay = date?.ex.days ?? 31
      }
    }
  }

  private var maxDay: Int? {
    didSet {
      calculate()
    }
  }

  public var date: Date? {
    didSet {
      if let date {
        maxMonth = date.ex.months
        current = currentFrom(date: date)
      }
    }
  }

  override func currentFrom(date: Date?) -> [Int] {
    if let date {
      [
        dataSource[0].lastIndex(of: date.ex.year) ?? 0,
        dataSource[1].lastIndex(of: date.ex.month) ?? 0,
        dataSource[2].lastIndex(of: date.ex.day) ?? 0,
      ]
    } else {
      dataSource.map(\.tail)
    }
  }

  override func selectedRowAction() {
    guard let selectedRow else { return }
    selectedRow.backgroundColor = .exBg
    selectedRow.layer.cornerRadius = 25
    for subview in selectedRow.subviews {
      if let v = subview as? UILabel {
        v.removeFromSuperview()
      }
    }
    guard units.count == 3 else { return }
    let rowSize = selectedRow.bounds.size
    let rowWidth = rowSize.width
    let rowHeight = rowSize.height
    let midX = rowWidth * 0.5
    let columnWidth = Self.kDateColumnWidth
    for i in 0 ..< units.count {
      let unitLabel = UILabel()
      unitLabel.text = units[i]
      unitLabel.textColor = UIColor(hex: 0x5F7CA0)
      unitLabel.font = .preferredFont(forTextStyle: .subheadline)
      unitLabel.sizeToFit()
      let numberTextWidthEstimate: CGFloat = (i == 0) ? 55 : 30
      let padding: CGFloat = 2.0
      let columnOffsetIndex = CGFloat(i - 1)
      let componentCenterX = midX + (columnOffsetIndex * columnWidth)
      let labelX = componentCenterX + (numberTextWidthEstimate / 2.0) + padding
      let labelY = (rowHeight - unitLabel.frame.height) / 2.0
      unitLabel.frame = CGRect(
        x: labelX,
        y: labelY,
        width: unitLabel.frame.width,
        height: unitLabel.frame.height,
      )
      selectedRow.addSubview(unitLabel)
    }
  }

  override func calculate() {
    let now = Date.now
    let year =
      switch (minYear, maxYear) {
      case let (.some(minY), .some(maxY)):
        (minY == maxY) ? [maxY] : Array(minY ... maxY)
      case let (.none, .some(maxY)): [maxY]
      case let (.some(minY), .none): [minY]
      case (.none, .none): Array(1900 ... (now.ex.year))
      }

    dataSource = [
      year,
      Array(1 ... (maxMonth ?? now.ex.month)),
      Array(1 ... (maxDay ?? now.ex.day)),
    ]
  }

  override func firstSelectCurrent() {
    current = dataSource.map(\.tail)
  }

  override func currentDateFrom(array: [Int]) -> Date? {
    let values = array.enumerated().map { component, row in
      dataSource[component][row]
    }
    return Date.ex.from(ymd: (values[0], values[1], values[2]))
  }
}

extension DatePicker {
  func pickerView(_: UIPickerView, widthForComponent _: Int) -> CGFloat {
    Self.kDateColumnWidth
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    var temp: [Int] = []
    if component == 0 {
      temp.append(contentsOf: [row, 0, 0])
    } else if component == 1 {
      temp.append(contentsOf: [current[0], row, 0])
    } else {
      temp.append(contentsOf: [current[0], current[1], row])
    }
    date = currentDateFrom(array: temp)
  }
}

#endif
