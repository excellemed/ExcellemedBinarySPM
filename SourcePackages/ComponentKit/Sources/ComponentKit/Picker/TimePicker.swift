#if canImport(UIKit)

import UIKit

public class TimePicker: PickerView {
  override func selectedRowAction() {
    guard let selectedRow else { return }
    selectedRow.backgroundColor = .exBg
    selectedRow.layer.cornerRadius = 25
    for subview in selectedRow.subviews {
      if let v = subview as? UILabel {
        v.removeFromSuperview()
      }
    }
    guard units.count == 2 else { return }
    let rowSize = selectedRow.bounds.size
    let midX = rowSize.width / 2.0
    let rowHeight = rowSize.height
    let columnWidth = Self.kTimeColumnWidth
    for i in 0 ..< units.count {
      let label = UILabel()
      label.text = units[i]
      label.textColor = UIColor(hex: 0x5F7CA0)
      label.font = .preferredFont(forTextStyle: .subheadline)
      label.sizeToFit()
      let numberWidthEstimate: CGFloat = 30.0
      let padding: CGFloat = 2.0
      let direction: CGFloat = (i == 0) ? -1.0 : 1.0
      let componentCenterX = midX + (direction * (columnWidth / 2.0))
      let x = componentCenterX + (numberWidthEstimate / 2.0) + padding
      let y = (rowHeight - label.frame.height) * 0.5
      label.frame = CGRect(
        x: x,
        y: y,
        width: label.frame.width,
        height: label.frame.height,
      )
      selectedRow.addSubview(label)
    }
  }

  var time: Date? {
    didSet {
      if let time {
        current = currentFrom(date: time)
      }
    }
  }

  override func currentDateFrom(array: [Int]) -> Date? {
    let values = array.enumerated().map { component, row in
      dataSource[component][row]
    }
    return Date.ex.from(hm: (values[0], values[1]))
  }

  override func currentFrom(date: Date?) -> [Int] {
    if let date {
      [
        dataSource[0].lastIndex(of: date.ex.hour) ?? 0,
        dataSource[1].lastIndex(of: date.ex.minute) ?? 0,
      ]
    } else {
      [
        dataSource[0].lastIndex(of: Date().ex.hour) ?? 0,
        dataSource[1].lastIndex(of: Date().ex.minute) ?? 0,
      ]
    }
  }

  override func calculate() {
    dataSource = [Array(0 ... 23), Array(0 ... 59)]
  }

  override func firstSelectCurrent() {
    current = currentFrom(date: time)
  }
}

extension TimePicker {
  func pickerView(_: UIPickerView, widthForComponent _: Int) -> CGFloat {
    Self.kTimeColumnWidth
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    var temp = current
    if temp.count > component {
      temp[component] = row
    } else {
      temp = [0, 0]
      temp[component] = row
    }
    time = currentDateFrom(array: temp)
  }
}

#endif
