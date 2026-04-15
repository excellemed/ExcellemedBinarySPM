#if canImport(UIKit)

import UIKit

public class OtherTimePicker: PickerView {
  override func selectedRowAction() {
    selectedRow?.backgroundColor = .exBg
    selectedRow?.layer.cornerRadius = 25
    selectedRow?.subviews.forEach {
      if let v = $0 as? UILabel {
        v.removeFromSuperview()
      }
    }
    for i in 0 ..< units.count {
      if let selectedRow {
        let label = UILabel()
        label.text = units[i]
        label.textColor = UIColor(hex: 0x5F7CA0)
        label.font = .preferredFont(forTextStyle: .subheadline)
        selectedRow.addSubview(label)
        let center = selectedRow.center
        let size = selectedRow.bounds.size
        let width = size.width
        let height = size.height
        let calculateLabel = UILabel()
        calculateLabel.font = .preferredFont(forTextStyle: .title3)
        label.sizeToFit()
        var x = 0.0
        if i == 0 {
          calculateLabel.text = "0000"
          calculateLabel.sizeToFit()
          x = 2 * calculateLabel.bounds.width + label.bounds.width * 0.5
        } else if i == 1 {
          x = center.x + label.bounds.width
        } else if i == 2 {
          calculateLabel.text = "00"
          calculateLabel.sizeToFit()
          x = width - calculateLabel.bounds.width * 2 - label.bounds.width * 0.5
        }

        label.frame = CGRect(
          x: x,
          y: (height - label.frame.height) * 0.5,
          width: label.frame.width,
          height: label.frame.height,
        )
      }
    }
  }

  public var time: Date? {
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
    let h = values[0] == TimePeriod.am.rawValue ? values[1] : values[1] + 12
    return Date.ex.from(hm: (h, values[2]))
  }

  override func currentFrom(date: Date?) -> [Int] {
    if let date {
      let isMorining = date.ex.hour < 12
      let timePeriod = isMorining ? TimePeriod.am.rawValue : TimePeriod.pm.rawValue
      let hour = isMorining ? date.ex.hour : date.ex.hour - 12
      let bb = [
        dataSource[0].lastIndex(of: timePeriod) ?? TimePeriod.am.rawValue,
        dataSource[1].lastIndex(of: hour) ?? 0,
        dataSource[2].lastIndex(of: date.ex.minute) ?? 0,
      ]
      return bb
    } else {
      let isMorining = Date().ex.hour < 12
      let timePeriod = isMorining ? TimePeriod.am.rawValue : TimePeriod.pm.rawValue
      let hour = isMorining ? Date().ex.hour : Date().ex.hour - 12
      let bb = [
        dataSource[0].lastIndex(of: timePeriod) ?? TimePeriod.am.rawValue,
        dataSource[1].lastIndex(of: hour) ?? 0,
        dataSource[2].lastIndex(of: Date().ex.minute) ?? 0,
      ]
      return bb
    }
  }

  override func calculate() {
    dataSource = [[TimePeriod.am.rawValue, TimePeriod.pm.rawValue], Array(0 ... 12), Array(0 ... 59)]
  }

  override func firstSelectCurrent() {
    current = currentFrom(date: time)
  }
}

public extension OtherTimePicker {
  func pickerView(_: UIPickerView, widthForComponent _: Int) -> CGFloat {
    Self.kTimeColumnWidth
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    current[component] = row
  }
}

#endif
