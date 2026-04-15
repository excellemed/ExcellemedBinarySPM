import UIKit

public class TooltipView: UIView {
  private let label = UILabel()
  private let arrowLayer = CAShapeLayer()
  
  var arrowCenterX: CGFloat = 0 { didSet { setNeedsLayout() } }
  var isArrowAtBottom: Bool = true { didSet { setNeedsLayout() } }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  private func setupUI() {
    backgroundColor = .white
    layer.cornerRadius = 12
    
    // 阴影
    layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
    layer.shadowOpacity = 1
    layer.shadowOffset = CGSize(width: 0, height: 2)
    layer.shadowRadius = 4
    
    // Label 设置
    label.font = .systemFont(ofSize: 13, weight: .medium)
    label.textColor = .darkGray
    label.numberOfLines = 0
    label.lineBreakMode = .byTruncatingTail
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    addSubview(label)
    
    let top = label.topAnchor.constraint(equalTo: topAnchor, constant: 8)
    let leading = label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12)
    let bottom = label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
    let trailing = label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
    
    bottom.priority = UILayoutPriority(999)
    trailing.priority = UILayoutPriority(999)
    
    NSLayoutConstraint.activate([top, leading, bottom, trailing])
    
    layer.addSublayer(arrowLayer)
  }
  
  func setMaxWidth(_ width: CGFloat) {
    label.preferredMaxLayoutWidth = width - 24
    setNeedsLayout()
    layoutIfNeeded()
  }
  
  func setText(_ text: String) {
    label.text = text
  }
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    
    let path = UIBezierPath()
    let arrowHeight: CGFloat = 6
    let arrowWidthHalf: CGFloat = 6
    
    let safeArrowX = min(max(arrowCenterX, layer.cornerRadius + arrowWidthHalf), bounds.width - layer.cornerRadius - arrowWidthHalf)
    
    if isArrowAtBottom {
      path.move(to: CGPoint(x: safeArrowX - arrowWidthHalf, y: bounds.height))
      path.addLine(to: CGPoint(x: safeArrowX, y: bounds.height + arrowHeight))
      path.addLine(to: CGPoint(x: safeArrowX + arrowWidthHalf, y: bounds.height))
    } else {
      path.move(to: CGPoint(x: safeArrowX - arrowWidthHalf, y: 0))
      path.addLine(to: CGPoint(x: safeArrowX, y: -arrowHeight))
      path.addLine(to: CGPoint(x: safeArrowX + arrowWidthHalf, y: 0))
    }
    path.close()
    
    arrowLayer.path = path.cgPath
    arrowLayer.fillColor = backgroundColor?.cgColor
    
    let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius)
    shadowPath.append(path)
    layer.shadowPath = shadowPath.cgPath
  }
}
