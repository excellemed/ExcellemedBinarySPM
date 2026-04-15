#if canImport(UIKit)

import UIKit

public nonisolated protocol DatePickerDelegate: AnyObject {
  func selected(date: Date)
}

public class PickerView: UIView {
  enum TimePeriod: Int {
    case am = 20000
    case pm = 30000
  }

  static let kDateColumnWidth: CGFloat = 95
  static let kTimeColumnWidth: CGFloat = 80

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  lazy var pickerView = UIPickerView()
  public weak var delegate: DatePickerDelegate?

  public var units: [String] = []

  public var selectedRow: UIView? {
    didSet {
      selectedRowAction()
    }
  }

  var dataSource: [[Int]] = [] {
    didSet {
      pickerView.reloadAllComponents()
    }
  }

  var current: [Int] = [] {
    didSet {
      for (component, row) in current.enumerated() {
        pickerView.selectRow(row, inComponent: component, animated: true)
        if let date = currentDateFrom(array: current), let delegate {
          delegate.selected(date: date)
        }
      }
    }
  }

  func currentDateFrom(array: [Int]) -> Date? { .none }

  func currentFrom(date: Date?) -> [Int] { [] }

  func firstSelectCurrent() {}

  func selectedRowAction() {}

  func calculate() {}
}

extension PickerView {
  private func setup() {
    addSubview(pickerView)
    pickerView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      pickerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      pickerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
      pickerView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
      pickerView.centerXAnchor.constraint(equalTo: centerXAnchor),
    ])
    pickerView.delegate = self
    pickerView.dataSource = self
    calculate()
  }
}

extension PickerView: UIPickerViewDelegate {
  public func pickerView(_: UIPickerView, rowHeightForComponent _: Int) -> CGFloat {
    50
  }

  public func text(component: Int, row: Int) -> Int {
    var text = 0
    if let column = dataSource[at: component] {
      text = column[at: row] ?? text
    }
    return text
  }

  public func pickerView(
    _: UIPickerView,
    viewForRow row: Int,
    forComponent component: Int,
    reusing view: UIView?,
  ) -> UIView {
    if let label = view as? UILabel {
      return label
    } else {
      let text = text(component: component, row: row)
      let label = UILabel()
      label.backgroundColor = .clear
      label.textAlignment = .center
      label.font = .preferredFont(forTextStyle: .title3)
      label.textColor = .black
      label.numberOfLines = 1
      label.adjustsFontSizeToFitWidth = true
      label.minimumScaleFactor = 1
      if text == TimePeriod.am.rawValue {
        label.text = "上午"
      } else if text == TimePeriod.pm.rawValue {
        label.text = "下午"
      } else {
        label.text = text.description
      }
      return label
    }
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    firstSelectCurrent()

    let pickerSubviews = pickerView.subviews
    if !pickerSubviews.isEmpty {
      if let first = pickerSubviews.first {
        if let columnViews = first.value(forKey: "subviewCache") as? [UIView],
           !columnViews.isEmpty,
           let firstColumn = columnViews.first,
           let selectedRow = firstColumn.value(forKey: "middleContainerView") as? UIView {
          self.selectedRow = selectedRow
        }
      }
    }

    if let last = pickerSubviews.last {
      last.isHidden = true
    }
  }
}

extension PickerView: UIPickerViewDataSource {
  public func numberOfComponents(in pickerView: UIPickerView) -> Int {
    dataSource.count
  }

  public func pickerView(_: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    dataSource[at: component]?.count ?? 0
  }
}

#endif
