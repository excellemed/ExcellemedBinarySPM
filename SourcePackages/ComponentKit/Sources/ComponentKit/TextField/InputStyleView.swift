#if canImport(UIKit)

import UIKit

public final class InputStyleView: UIButton {
  public var placeholder: String = "" {
    didSet {
      placeholderLabel.text = placeholder
    }
  }

  public var rightView: UIImage? {
    didSet {
      icon.image = rightView
    }
  }

  public var value: String = "" {
    didSet {
      textLabel.text = value
      placeholderLabel.isHidden = !value.isEmpty
    }
  }

  public let textLabel = UILabel()
  private let placeholderLabel = UILabel()
  private let icon = UIImageView()

  public init() {
    super.init(frame: .zero)
    setup()
  }

  private func setup() {
    placeholderLabel.textColor = .exDeepGray
    placeholderLabel.font = .preferredFont(forTextStyle: .footnote)
    placeholderLabel.lineBreakMode = .byTruncatingTail
    placeholderLabel.numberOfLines = 1

    textLabel.textColor = .exBlack
    textLabel.font = .preferredFont(forTextStyle: .footnote)
    textLabel.lineBreakMode = .byTruncatingTail
    textLabel.numberOfLines = 1

    addSubview(placeholderLabel)
    addSubview(icon)
    addSubview(textLabel)

    placeholderLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
    let placeholderTrailing = placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: icon.leadingAnchor, constant: -10)
    placeholderTrailing.priority = .defaultHigh
    NSLayoutConstraint.activate([
      placeholderLabel.leadingAnchor.constraint(equalTo: placeholderLabel.superview!.leadingAnchor, constant: 15),
      placeholderLabel.centerYAnchor.constraint(equalTo: placeholderLabel.superview!.centerYAnchor),
      placeholderTrailing,
    ])

    textLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    textLabel.translatesAutoresizingMaskIntoConstraints = false
    let textTrailing = textLabel.trailingAnchor.constraint(lessThanOrEqualTo: icon.leadingAnchor, constant: -10)
    textTrailing.priority = .defaultHigh
    NSLayoutConstraint.activate([
      textLabel.leadingAnchor.constraint(equalTo: textLabel.superview!.leadingAnchor, constant: 15),
      textLabel.centerYAnchor.constraint(equalTo: textLabel.superview!.centerYAnchor),
      textTrailing,
    ])

    icon.setContentCompressionResistancePriority(.required, for: .horizontal)
    icon.setContentHuggingPriority(.required, for: .horizontal)
    icon.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      icon.centerYAnchor.constraint(equalTo: icon.superview!.centerYAnchor),
      icon.trailingAnchor.constraint(equalTo: icon.superview!.trailingAnchor, constant: -15),
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private let textDidSubject = PassthroughSubject<String?, Never>()

  public var textDidChangePubliser: AnyPublisher<String?, Never> {
    textDidSubject.eraseToAnyPublisher()
  }
}

public extension Reactive where Base: InputStyleView {
  var text: ControlProperty<String?> {
    let src = base.textDidChangePubliser.prepend(base.value).eraseToAnyPublisher()
    let binder = Binder(base) {
      $0.value = $1 ?? ""
    }
    return ControlProperty(values: src, valueSink: binder)
  }
}

#endif
