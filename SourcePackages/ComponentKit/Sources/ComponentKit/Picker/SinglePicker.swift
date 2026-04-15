import UIKit

public class SinglePicker<T: CustomStringConvertible>: UIView,
  UIPickerViewDelegate,
  UIPickerViewDataSource
{
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public var onSelected: ((T) -> Void)?

  public init() {
    super.init(frame: .zero)
    addSubview(pickerView)
    pickerView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      pickerView.widthAnchor.constraint(equalToConstant: 200),
      pickerView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
      pickerView.centerXAnchor.constraint(equalTo: centerXAnchor),
    ])
    pickerView.delegate = self
    pickerView.dataSource = self
  }

  private lazy var pickerView = UIPickerView()
  public var data: [T] = []
  public var unit: String = ""

  public override func layoutSubviews() {
    super.layoutSubviews()
    pickerView.selectRow(0, inComponent: 0, animated: false)
    pickerView(pickerView, didSelectRow: 0, inComponent: 0)
  }

  public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    onSelected?(data[row])
  }

  public func pickerView(
    _ pickerView: UIPickerView,
    viewForRow row: Int,
    forComponent component: Int,
    reusing view: UIView?
  ) -> UIView {
    let text = data[row]

    let pickerSubviews = pickerView.subviews
    if !pickerSubviews.isEmpty {
      if let first = pickerSubviews.first {
        if let columns = first.value(forKey: "subviewCache") as? [UIView],
          !columns.isEmpty,
          let firstColumn = columns.first,
          let selectedRow = firstColumn.value(forKey: "middleContainerView") as? UIView
        {
          selectedRow.backgroundColor = .exBg
          selectedRow.layer.cornerRadius = 25

          if !unit.isEmpty {
            let label = UILabel()
            label.text = unit
            label.textColor = UIColor(hex: 0x5F7CA0)
            label.font = .preferredFont(forTextStyle: .subheadline)
            selectedRow.addSubview(label)
            let center = selectedRow.center
            let size = selectedRow.bounds.size
            let height = size.height
            let calculateLabel = UILabel()
            calculateLabel.font = .preferredFont(forTextStyle: .title3)
            label.sizeToFit()
            let x = center.x + label.bounds.width

            label.frame = CGRect(
              x: x,
              y: (height - label.frame.height) * 0.5,
              width: label.frame.width,
              height: label.frame.height
            )
          }
        }
      }
    }

    if let last = pickerSubviews.last {
      last.isHidden = true
    }

    if let label = view as? UILabel {
      return label
    } else {
      let label = UILabel()
      label.backgroundColor = .clear
      label.textAlignment = .center
      label.font = .preferredFont(forTextStyle: .title3)
      label.textColor = .black
      label.numberOfLines = 1
      label.adjustsFontSizeToFitWidth = true
      label.minimumScaleFactor = 0.6
      label.text = text.description
      return label
    }
  }

  public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
    50
  }

  public func numberOfComponents(in pickerView: UIPickerView) -> Int {
    1
  }

  public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    data.count
  }
}
