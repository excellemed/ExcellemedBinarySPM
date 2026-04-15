#if canImport(UIKit)

import UIKit
import ToolKit

public protocol CheckboxShape {
  func path(in rect: CGRect) -> UIBezierPath
}

public class Checkbox: UIButton {
  public var fillColor = UIColor.exGreen {
    didSet {
      reset()
      setup()
      layoutSubviews()
    }
  }
  public var markColor = UIColor.white {
    didSet {
      reset()
      setup()
      layoutSubviews()
    }
  }
  public var markWidth: CGFloat = 1.0 {
    didSet {
      reset()
      setup()
      layoutSubviews()
    }
  }
  public var strokeWidth: CGFloat = 1.0 {
    didSet {
      reset()
      setup()
      layoutSubviews()
    }
  }
  public var strokeColor = UIColor.exLightGray
  
  public var shape: any CheckboxShape = Circle() {
    didSet {
      reset()
      setup()
      layoutSubviews()
    }
  }
  
  private var _checked = false
  
  private var borderLayer = NoImplicitActionLayer()
  private var shapeLayer = NoImplicitActionLayer()
  
  public override var intrinsicContentSize: CGSize {
    CGSize(width: 18, height: 18)
  }
  
  public init() {
    super.init(frame: .zero)
    reset()
    setup()
  }
  
  public convenience init(shape: any CheckboxShape) {
    self.init()
    self.shape = shape
    reset()
    setup()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    updatePath()
  }
  
  public var isChecked: Bool {
    get { _checked }
    set { setChecked(newValue, animated: true) }
  }
  
  public var isCheckedNoAnimation: Bool {
    get { _checked }
    set { setChecked(newValue, animated: false) }
  }
  
  public func setChecked(_ checked: Bool, animated: Bool) {
    guard _checked != checked else { return }
    _checked = checked
    updateState(animated: animated)
  }
  
  public func toggle(animated: Bool = true) {
    setChecked(!_checked, animated: animated)
  }
}


extension Checkbox {
  private func reset() {
    borderLayer.removeFromSuperlayer()
    shapeLayer.removeFromSuperlayer()
    removeTarget(self, action: #selector(handleTouchUp), for: .touchUpInside)
  }

  private func setup() {
    backgroundColor = .clear
    borderLayer.fillColor = UIColor.clear.cgColor
    borderLayer.lineWidth = strokeWidth
    layer.addSublayer(borderLayer)
    
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.lineWidth = markWidth
    shapeLayer.lineCap = .round
    shapeLayer.lineJoin = .round
    shapeLayer.strokeColor = markColor.cgColor
    shapeLayer.strokeEnd = 0
    layer.addSublayer(shapeLayer)
    addTarget(self, action: #selector(handleTouchUp), for: .touchUpInside)
  }
  
  @objc private func handleTouchUp() {
    toggle()
    sendActions(for: .valueChanged)
  }
  
  private func updatePath() {
    guard bounds.width > 0 && bounds.height > 0 else { return }
    
    let bgPath = shape.path(in: bounds)
    borderLayer.path = bgPath.cgPath
    
    let path = UIBezierPath()
    path.move(to: CGPoint(x: bounds.width * 0.28, y: bounds.height * 0.5))
    path.addLine(to: CGPoint(x: bounds.width * 0.44, y: bounds.height * 0.66))
    path.addLine(to: CGPoint(x: bounds.width * 0.72, y: bounds.height * 0.36))
    shapeLayer.path = path.cgPath
    
    updateState(animated: false)
  }
  
  private func updateState(animated: Bool) {
    let targetFillColor = _checked ? fillColor.cgColor : UIColor.clear.cgColor
    let targetStrokeColor = _checked ? UIColor.clear.cgColor : strokeColor.cgColor
    let targetStrokeEnd: CGFloat = _checked ? 1.0 : 0.0
    
    borderLayer.removeAllAnimations()
    shapeLayer.removeAllAnimations()
    
    if animated {
      let duration: TimeInterval = 0.3
      let timingFn = CAMediaTimingFunction(name: .easeInEaseOut)
      
      animateProperty(layer: borderLayer, key: "fillColor", to: targetFillColor, duration: duration, timing: timingFn)
      animateProperty(layer: borderLayer, key: "strokeColor", to: targetStrokeColor, duration: duration, timing: timingFn)
      animateProperty(layer: shapeLayer, key: "strokeEnd", to: targetStrokeEnd, duration: duration, timing: timingFn)
      
      shapeLayer.strokeEnd = targetStrokeEnd
      borderLayer.fillColor = targetFillColor
      borderLayer.strokeColor = targetStrokeColor
    } else {
      shapeLayer.strokeEnd = targetStrokeEnd
      borderLayer.fillColor = targetFillColor
      borderLayer.strokeColor = targetStrokeColor
    }
  }
  
  private func animateProperty(layer: CALayer, key: String, to target: Any, duration: TimeInterval, timing: CAMediaTimingFunction) {
    let animation = CABasicAnimation(keyPath: key)
    animation.fromValue = layer.presentation()?.value(forKey: key) ?? layer.value(forKey: key)
    animation.toValue = target
    animation.duration = duration
    animation.timingFunction = timing
    layer.add(animation, forKey: key)
  }
}

extension Checkbox {
  fileprivate class NoImplicitActionLayer: CAShapeLayer {
    override func action(forKey event: String) -> (any CAAction)? {
      return nil
    }
  }
  
  public struct Circle: CheckboxShape {
    public init() {}
    public func path(in rect: CGRect) -> UIBezierPath {
      let ringRect = rect.insetBy(dx: 1, dy: 1)
      return UIBezierPath(ovalIn: ringRect)
    }
  }
  
  public struct Rounded: CheckboxShape {
    public let cornerRadius: CGFloat
    public init(_ cornerRadius: CGFloat) {
      self.cornerRadius = cornerRadius
    }
    
    public func path(in rect: CGRect) -> UIBezierPath {
      let ringRect = rect.insetBy(dx: 1, dy: 1)
      return UIBezierPath(roundedRect: ringRect, cornerRadius: cornerRadius)
    }
  }
}


public final class RoundedCheckBox: Checkbox {
  public override init() {
    super.init()
    self.shape = Checkbox.Rounded(2)
  }
}

#endif
