#if canImport(UIKit)

import UIKit

public class InformationCard: UIControl {
  
  private let hStack: UIStackView = {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.alignment = .center
    stack.spacing = 16
    stack.isLayoutMarginsRelativeArrangement = true
    stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
    stack.isUserInteractionEnabled = false
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()
  
  private let icon: UIImageView = {
    let view = UIImageView()
    view.contentMode = .scaleAspectFit
    view.isUserInteractionEnabled = false
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let vStack: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.alignment = .fill
    stack.spacing = 2
    stack.isUserInteractionEnabled = false
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.setContentHuggingPriority(.defaultLow, for: .horizontal)
    return stack
  }()
  
  private let title: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 15)
    label.adjustsFontForContentSizeCategory = true
    label.textColor = .exBlack
    label.numberOfLines = 1
    label.isUserInteractionEnabled = false
    return label
  }()
  
  private let hint: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12)
    label.adjustsFontForContentSizeCategory = true
    label.textColor = .exDeepGray
    label.numberOfLines = 0
    label.isUserInteractionEnabled = false
    return label
  }()
  
  private let arrowView: UIImageView = {
    let view = UIImageView()
    view.contentMode = .scaleAspectFit
    let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .light)
    view.image = UIImage(systemName: "chevron.right", withConfiguration: config)
    view.tintColor = .exDeepGray
    view.isHidden = true
    view.isUserInteractionEnabled = false
    view.translatesAutoresizingMaskIntoConstraints = false
    
    view.setContentHuggingPriority(.required, for: .horizontal)
    view.setContentCompressionResistancePriority(.required, for: .horizontal)
    return view
  }()
  
  public var isShowArrow: Bool {
    get { !arrowView.isHidden }
    set { arrowView.isHidden = !newValue }
  }
  
  public override var isHighlighted: Bool {
    didSet {
      UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction]) {
        self.backgroundColor = self.isHighlighted ? .tertiarySystemFill : .secondarySystemGroupedBackground
        self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
      }
    }
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
    setupAppearance()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    setupAppearance()
  }
  
  private func setup() {
    addSubview(hStack)
    
    vStack.addArrangedSubview(title)
    vStack.addArrangedSubview(hint)
    
    hStack.addArrangedSubview(icon)
    hStack.addArrangedSubview(vStack)
    hStack.addArrangedSubview(arrowView)
    
    NSLayoutConstraint.activate([
      hStack.topAnchor.constraint(equalTo: topAnchor),
      hStack.leadingAnchor.constraint(equalTo: leadingAnchor),
      hStack.trailingAnchor.constraint(equalTo: trailingAnchor),
      hStack.bottomAnchor.constraint(equalTo: bottomAnchor),
      hStack.heightAnchor.constraint(equalToConstant: 64),
      
      icon.widthAnchor.constraint(equalToConstant: 32),
      icon.heightAnchor.constraint(equalToConstant: 32),
      
      arrowView.widthAnchor.constraint(equalToConstant: 14),
      arrowView.heightAnchor.constraint(equalToConstant: 14)
    ])
  }
  
  private func setupAppearance() {
    backgroundColor = .secondarySystemGroupedBackground
    layer.cornerRadius = 16
    layer.masksToBounds = true
    layer.cornerCurve = .continuous
  }
  
  // MARK: - Configuration
  
  /// 配置卡片内容
  /// - Parameters:
  ///   - titleText: 标题
  ///   - hintText: 副标题/提示
  ///   - iconImage: 图标
  ///   - showArrow: 是否显示右侧跳转箭头 (默认 false)
  public func configure(titleText: String, hintText: String, iconImage: UIImage?, showArrow: Bool = false) {
    self.title.text = titleText
    self.hint.text = hintText
    self.icon.image = iconImage?.withRenderingMode(.alwaysOriginal)
    self.isShowArrow = showArrow // 更新箭头状态
  }
}

#endif
