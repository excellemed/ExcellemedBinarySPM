#if os(iOS)

import UIKit

public class InputField: UITextField {
  public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    false
  }
}

public class CodeView: UIView {
  public var text: String? {
    didSet {
      if let text, !text.isEmpty {
        label.text = String(text.prefix(1))
        line.backgroundColor = UIColor.exLightPurple
      } else {
        label.text = ""
        line.backgroundColor = UIColor.exBg
      }
    }
  }

  private lazy var line: UIView = {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    v.backgroundColor = .exBg
    return v
  }()

  private lazy var label: UILabel = {
    let l = UILabel()
    l.translatesAutoresizingMaskIntoConstraints = false
    l.textColor = UIColor.exBlack
    l.font = UIFont.preferredFont(forTextStyle: .title3)
    l.textAlignment = .center
    return l
  }()

  public override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
    isUserInteractionEnabled = false
    addSubview(label)
    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: topAnchor),
      label.leadingAnchor.constraint(equalTo: leadingAnchor),
      label.trailingAnchor.constraint(equalTo: trailingAnchor),
      label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
    ])
    addSubview(line)
    NSLayoutConstraint.activate([
      line.bottomAnchor.constraint(equalTo: bottomAnchor),
      line.leadingAnchor.constraint(equalTo: leadingAnchor),
      line.trailingAnchor.constraint(equalTo: trailingAnchor),
      line.heightAnchor.constraint(equalToConstant: 2),
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

public class CaptchaTextField: UIView {
  public init(len: UInt = 4) {
    super.init(frame: .zero)
    self.len = len
    addSubview(textField)
    NSLayoutConstraint.activate([
      textField.leadingAnchor.constraint(equalTo: leadingAnchor),
      textField.trailingAnchor.constraint(equalTo: trailingAnchor),
      textField.topAnchor.constraint(equalTo: topAnchor),
      textField.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
    textField.delegate = self
    for _ in 0 ..< len {
      let v = CodeView()
      v.translatesAutoresizingMaskIntoConstraints = false
      fields.append(v)
      addSubview(v)
      let leading = v.leftAnchor.constraint(equalTo: leftAnchor)
      let width = v.widthAnchor.constraint(equalToConstant: 0)
      NSLayoutConstraint.activate([
        leading,
        v.topAnchor.constraint(equalTo: topAnchor),
        v.bottomAnchor.constraint(equalTo: bottomAnchor),
        width,
      ])
      leadingConstraints.append(leading)
      widthConstraints.append(width)
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var complete: ((String) -> Void)?
  var incomplete: ((String) -> Void)?
  let textField = {
    let field = InputField()
    field.backgroundColor = .clear
    field.textColor = .clear
    field.keyboardType = .numberPad
    field.returnKeyType = .done
    field.tintColor = .clear
    field.translatesAutoresizingMaskIntoConstraints = false
    return field
  }()
  private var current: Int = 0
  private var fields = [CodeView]()
  private var leadingConstraints = [NSLayoutConstraint]()
  private var widthConstraints = [NSLayoutConstraint]()
  private var len: UInt = 4
}

extension CaptchaTextField {
  public override func layoutSubviews() {
    super.layoutSubviews()
    let width = bounds.size.width / (CGFloat(len) * 1.5 - 0.5)
    for (index, _) in fields.enumerated() {
      leadingConstraints[index].constant = width * 1.5 * CGFloat(index)
      widthConstraints[index].constant = width
    }
  }
}

extension CaptchaTextField: UITextFieldDelegate {
  public func textField(
    _ textField: UITextField,
    shouldChangeCharactersIn range: NSRange,
    replacementString string: String
  ) -> Bool {
    if string == "\n" {
      textField.resignFirstResponder()
      return false
    }
    if string.isEmpty {
      if range.length > 0, current > 0 {
        fields[current - 1].text = ""
        current -= 1
        incomplete?(String(textField.text?.prefix(current) ?? ""))
      }
      return true
    }
    guard Int(string) != .none else {
      return false
    }
    if let text = textField.text, text.count + string.count > len {
      return false
    }
    if let field = fields[at: current] {
      field.text = string
      current += 1
      if current == len, let text = textField.text {
        complete?(text + string)
      } else {
        incomplete?(String(textField.text?.prefix(current) ?? "") + string)
      }
      return true
    }
    return false
  }
}

extension Reactive where Base: CaptchaTextField {
  @MainActor
  public var text: ControlProperty<String> {
    let src = base.textField.rx.text.orEmpty.asObservable()
    let bindingObserver: Binder<String> = Binder(base) { t, text in
      t.textField.text = text
    }
    return ControlProperty(values: src, valueSink: bindingObserver)
  }
}

#endif
