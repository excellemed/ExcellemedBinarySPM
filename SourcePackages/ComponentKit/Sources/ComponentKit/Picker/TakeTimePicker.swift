import UIKit

public class TakeTimePicker: PickerView {
  override func selectedRowAction() {
    selectedRow?.backgroundColor = .exBg
    selectedRow?.layer.cornerRadius = 25
    selectedRow?.subviews.forEach {
      if let v = $0 as? UILabel {
        v.removeFromSuperview()
      }
    }
    for i in 0..<units.count {
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
          x = 2 * calculateLabel.bounds.width + label.bounds.width * 1.3
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
          height: label.frame.height
        )
      }
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
    return Date.ex.from(hms: (values[0], values[1], values[2]))
  }

  override func currentFrom(date: Date?) -> [Int] {
    if let date {
      [
        dataSource[0].lastIndex(of: date.ex.hour) ?? 0,
        dataSource[1].lastIndex(of: date.ex.minute) ?? 0,
        dataSource[2].lastIndex(of: date.ex.second) ?? 0,
      ]
    } else {
      [
        0, 0, 0,
      ]
    }
  }

  override func calculate() {
    dataSource = [Array(0...23), Array(0...59), Array(0...59)]
  }

  override func firstSelectCurrent() {
    current = currentFrom(date: time)
  }
}

extension TakeTimePicker {
  func pickerView(_: UIPickerView, widthForComponent _: Int) -> CGFloat {
    Self.kTimeColumnWidth
  }
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    current[component] = row
  }
}
