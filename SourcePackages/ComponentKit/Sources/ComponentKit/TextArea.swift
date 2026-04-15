import UIKit

public final class TextArea: UIView {
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private var subscriptions = Set<AnyCancellable>()

  public init(tipText: String, placeholderText: String = "填写备注") {
    super.init(frame: .zero)
    setup(tipText: tipText, placeholderText: placeholderText)
  }

  public var text: String { textView.text }
  public var isEditable: Bool {
    get { textView.isEditable }
    set { textView.isEditable = newValue }
  }

  public let textView = UITextView()
  private let placeholderLabel = UILabel()
  private let tipLabel = UILabel()
}

extension TextArea {
  private func setup(tipText: String, placeholderText: String) {
    clipsToBounds = false
    backgroundColor = .white
    layer.borderColor = UIColor(hex: 0xDEEBF4).cgColor
    layer.borderWidth = 2
    layer.cornerRadius = 20
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.font = .preferredFont(forTextStyle: .subheadline)
    textView.textColor = .exBlack
    textView.isScrollEnabled = true
    textView.backgroundColor = .clear

    placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
    placeholderLabel.text = placeholderText
    placeholderLabel.font = .preferredFont(forTextStyle: .subheadline)
    placeholderLabel.textColor = .exDeepGray

    tipLabel.translatesAutoresizingMaskIntoConstraints = false
    tipLabel.text = tipText
    tipLabel.font = .preferredFont(forTextStyle: .caption1)
    tipLabel.textColor = .exDeepGray

    addSubview(textView)
    addSubview(placeholderLabel)
    addSubview(tipLabel)
    NSLayoutConstraint.activate([
      textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
      textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
      textView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
      textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18),
      placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
      placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
      tipLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
      tipLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -9),
    ])

    rx.text.map { !$0.isEmpty }
      .bind(to: placeholderLabel.rx.isHidden)
      .store(in: &subscriptions)
  }
}

extension Reactive where Base: TextArea {
  @MainActor
  public var text: ControlProperty<String> {
    base.textView.rx.text.orEmpty
  }

  @MainActor
  public func text(maxLength: Int) -> ControlProperty<String> {
    let src = base.rx.text.map {
      String($0.prefix(maxLength))
    }

    let bindingObserver: Binder<String> = Binder(base) { t, text in
      t.textView.text = String(text.prefix(maxLength))
    }
    return ControlProperty(values: src, valueSink: bindingObserver)
  }
}
