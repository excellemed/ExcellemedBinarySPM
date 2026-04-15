#if canImport(UIKit)

import UIKit

public class SelectionBox: UIControl {
  public let checkbox: Checkbox

  public var iconSize: CGFloat = 20.0 {
    didSet {
      widthConstraint?.constant = iconSize
      heightConstraint?.constant = iconSize
    }
  }

  public var title: String? {
    get { titleLabel.text }
    set { titleLabel.text = newValue }
  }

  public var isChecked: Bool {
    get { checkbox.isChecked }
    set { checkbox.isChecked = newValue }
  }

  override public var isEnabled: Bool {
    didSet {
      alpha = isEnabled ? 1.0 : 0.4
      isUserInteractionEnabled = isEnabled
    }
  }

  private let stackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.alignment = .center
    stack.spacing = 10
    stack.isUserInteractionEnabled = false
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 15)
    label.textColor = .exBlack
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private var widthConstraint: NSLayoutConstraint?
  private var heightConstraint: NSLayoutConstraint?

  public init(boxShape: any CheckboxShape = Checkbox.Circle()) {
    self.checkbox = Checkbox(shape: boxShape)
    super.init(frame: .zero)
    setup()
  }

  public required init?(coder: NSCoder) {
    self.checkbox = Checkbox()
    super.init(coder: coder)
    setup()
  }

  private func setup() {
    checkbox.isUserInteractionEnabled = false
    checkbox.translatesAutoresizingMaskIntoConstraints = false

    addSubview(stackView)
    stackView.addArrangedSubview(checkbox)
    stackView.addArrangedSubview(titleLabel)

    widthConstraint = checkbox.widthAnchor.constraint(equalToConstant: iconSize)
    heightConstraint = checkbox.heightAnchor.constraint(equalToConstant: iconSize)
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor),
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

      widthConstraint!,
      heightConstraint!,
    ])

    titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    checkbox.setContentCompressionResistancePriority(.required, for: .horizontal)

    addTarget(self, action: #selector(handleTap), for: .touchUpInside)
  }

  @objc private func handleTap() {
    checkbox.toggle(animated: true)
    let feedback = UIImpactFeedbackGenerator(style: .light)
    feedback.impactOccurred()
    sendActions(for: .valueChanged)
  }
}

extension Reactive where Base: UIControl {
  var tap: AnyPublisher<Void, Never> {
    controlEvent(for: .touchUpInside)
  }
}

#endif
