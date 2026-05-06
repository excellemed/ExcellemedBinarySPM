#if canImport(UIKit)

import UIKit
import Combine
import ToolKit

public nonisolated protocol TimelineDataDisplayable: Codable {
  var time: TimeInterval { get }
  var id: String? { get }
}

public final class HorizontalWrapperBar<T: TimelineDataDisplayable>: UIView {
  public enum Style {
    case circle
    case square(CGFloat)
  }
  
  private let iconSize: CGFloat = 20
  private let pointSize: CGFloat = 6
  private let defaultBgColor = UIColor(hex: 0xF6F8FB)
  
  private let style: Style
  
  private let trackView = UIView()
  private let pointLayer = CAShapeLayer()
  private let iconView: MutableColorIcon
  
  private lazy var dismissOverlay: UIButton = {
    let btn = UIButton(type: .custom)
    btn.backgroundColor = .clear
    btn.addTarget(self, action: #selector(hideTooltip), for: .touchUpInside)
    return btn
  }()
  
  private var activeTooltip: TooltipView?
  private weak var keyWindow: UIWindow? {
    return window ?? UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
  }
  
  public var anchorDate: Date = .now { didSet { setNeedsLayout() } }
  public var range: ClosedRange<Int>? { didSet { setNeedsLayout() } }
  public var data: [T] = [] { didSet { setNeedsLayout() } }
  
  public var textProvider: ((T) -> String)? {
    didSet {
      isUserInteractionEnabled = textProvider != nil
      if textProvider != nil { setupGesture() }
    }
  }

  public init(icon: UIImage, color: UIColor, style: Style = .circle) {
    self.style = style
    self.iconView = MutableColorIcon(icon)
    super.init(frame: .zero)
    setupUI(themeColor: color)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }
  
  private func setupUI(themeColor: UIColor) {
    backgroundColor = .clear
    
    trackView.backgroundColor = defaultBgColor
    trackView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(trackView)
    
    iconView.backgroundColor = themeColor
    iconView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(iconView)
    
    if case .square = style {
      NSLayoutConstraint.activate([
        iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
        iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
        iconView.widthAnchor.constraint(equalToConstant: iconSize),
        iconView.heightAnchor.constraint(equalToConstant: iconSize),
        
        trackView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
        trackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        trackView.topAnchor.constraint(equalTo: topAnchor),
        trackView.bottomAnchor.constraint(equalTo: bottomAnchor)
      ])
    } else {
      NSLayoutConstraint.activate([
        trackView.leadingAnchor.constraint(equalTo: leadingAnchor),
        trackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        trackView.topAnchor.constraint(equalTo: topAnchor),
        trackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        
        iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
        iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
        iconView.widthAnchor.constraint(equalToConstant: iconSize),
        iconView.heightAnchor.constraint(equalToConstant: iconSize)
      ])
    }
    
    pointLayer.fillColor = themeColor.cgColor
    trackView.layer.addSublayer(pointLayer)
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    switch style {
    case .circle:
      trackView.layer.cornerRadius = bounds.height * 0.5
    case .square(let radius):
      trackView.layer.cornerRadius = radius
    }
    
    pointLayer.frame = trackView.bounds
    updatePoint()
  }
  
  private func normalizeX(date: Date, start: Date, end: Date) -> CGFloat {
    let total = end.timeIntervalSince(start)
    guard total > 0 else { return 0 }
    let offset = date.timeIntervalSince(start)
    
    let trackWidth = trackView.bounds.width
    
    if case .circle = style {
      let startX: CGFloat = 28
      let availableWidth = trackWidth - startX - 10
      return startX + (CGFloat(offset / total) * availableWidth)
    } else {
      let startX: CGFloat = 10
      let availableWidth = trackWidth - startX - 10
      return startX + (CGFloat(offset / total) * availableWidth)
    }
  }
  
  private func updatePoint() {
    guard !data.isEmpty, let lower = range?.lowerBound, let upper = range?.upperBound, trackView.bounds.width > 0 else {
      pointLayer.path = nil; return
    }
    
    guard let (start, end) = calculateDateRange(lower: lower, upper: upper) else {
      pointLayer.path = nil; return
    }
    
    let path = CGMutablePath()
    for item in data {
      let itemDate = Date(timeIntervalSince1970: item.time)
      if itemDate < start || itemDate > end { continue }
      
      let x = normalizeX(date: itemDate, start: start, end: end)
      let centerY = trackView.bounds.height * 0.5
      
      path.addArc(center: CGPoint(x: x, y: centerY), radius: pointSize * 0.5, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
    }
    pointLayer.path = path
  }
  
  private func calculateDateRange(lower: Int, upper: Int) -> (start: Date, end: Date)? {
    let anchor = anchorDate.ex.startOfDay
    guard let startDate = anchor.ex.from(hm: (lower, 0)) else { return nil }
    let endDate: Date
    if upper == 24 {
      endDate = anchor.ex.add(.day(1))
    } else {
      guard let date = anchor.ex.from(hm: (upper, 0)) else { return nil }
      endDate = date
    }
    return (startDate, endDate)
  }
  
  private func setupGesture() {
    if gestureRecognizers?.isEmpty ?? true {
      let tap = UITapGestureRecognizer(target: self, action: #selector(handleBarTap(_:)))
      addGestureRecognizer(tap)
    }
  }
  
  @objc private func handleBarTap(_ gesture: UITapGestureRecognizer) {
    guard let provider = textProvider else { return }
    
    let locationInTrack = gesture.location(in: trackView)
    
    if case .square = style, !trackView.bounds.contains(locationInTrack) {
      hideTooltip()
      return
    }
    
    if let (item, itemX) = findItem(at: locationInTrack.x) {
      showTooltip(text: provider(item), atX: itemX)
    } else {
      hideTooltip()
    }
  }
  
  private func findItem(at touchX: CGFloat) -> (item: T, x: CGFloat)? {
    guard !data.isEmpty, let lower = range?.lowerBound, let upper = range?.upperBound,
          let (start, end) = calculateDateRange(lower: lower, upper: upper), trackView.bounds.width > 0 else { return nil }
    
    let hitRadius: CGFloat = 20.0
    var closest: (T, CGFloat, CGFloat)?
    
    for item in data {
      let itemDate = Date(timeIntervalSince1970: item.time)
      if itemDate < start || itemDate > end { continue }
      
      let x = normalizeX(date: itemDate, start: start, end: end)
      let dist = abs(touchX - x)
      if dist < hitRadius {
        if closest == nil || dist < closest!.2 { closest = (item, x, dist) }
      }
    }
    if let c = closest { return (c.0, c.1) }
    return nil
  }
  
  private func showTooltip(text: String, atX x: CGFloat) {
    guard let window = keyWindow else { return }
    
    if activeTooltip == nil {
      activeTooltip = TooltipView()
      activeTooltip?.alpha = 0
      let tapSelf = UITapGestureRecognizer(target: self, action: #selector(hideTooltip))
      activeTooltip?.addGestureRecognizer(tapSelf)
      activeTooltip?.isUserInteractionEnabled = true
    }
    let tooltip = activeTooltip!
    tooltip.setText(text)
    
    if dismissOverlay.superview != window {
      dismissOverlay.frame = window.bounds
      window.addSubview(dismissOverlay)
    }
    if tooltip.superview != window {
      window.addSubview(tooltip)
    }
    window.bringSubviewToFront(tooltip)
    
    let margin: CGFloat = 12
    let maxAllowedWidth = window.bounds.width - (margin * 2)
    tooltip.setMaxWidth(maxAllowedWidth)
    
    let size = tooltip.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    let pointInWindow = trackView.convert(CGPoint(x: x, y: trackView.bounds.height/2), to: window)
    let arrowHeight: CGFloat = 6
    let spacing: CGFloat = 4
    let safeBounds = window.safeAreaLayoutGuide.layoutFrame
    
    var tooltipFrame = CGRect(
      x: pointInWindow.x - size.width / 2,
      y: pointInWindow.y - size.height - arrowHeight - spacing,
      width: size.width,
      height: size.height
    )
    var isArrowAtBottom = true
    
    if tooltipFrame.minY < safeBounds.minY + margin {
      tooltipFrame.origin.y = pointInWindow.y + arrowHeight + spacing
      isArrowAtBottom = false
    }
    
    if tooltipFrame.minX < margin {
      tooltipFrame.origin.x = margin
    } else if tooltipFrame.maxX > window.bounds.width - margin {
      tooltipFrame.origin.x = window.bounds.width - margin - tooltipFrame.width
    }
    
    tooltip.arrowCenterX = pointInWindow.x - tooltipFrame.origin.x
    tooltip.isArrowAtBottom = isArrowAtBottom
    tooltip.frame = tooltipFrame
    tooltip.setNeedsLayout()
    tooltip.layoutIfNeeded()
    
    UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: []) {
      tooltip.alpha = 1
      tooltip.transform = .identity
    }
  }
  
  @objc private func hideTooltip() {
    guard let tooltip = activeTooltip else { return }
    UIView.animate(withDuration: 0.15, animations: {
      tooltip.alpha = 0
    }) { _ in
      tooltip.removeFromSuperview()
      self.dismissOverlay.removeFromSuperview()
      self.activeTooltip = nil
    }
  }
  
  public override func willMove(toWindow newWindow: UIWindow?) {
    super.willMove(toWindow: newWindow)
    if newWindow == nil {
      activeTooltip?.removeFromSuperview()
      dismissOverlay.removeFromSuperview()
      activeTooltip = nil
    }
  }
}

public extension Array where Element: TimelineDataDisplayable {
  func mergedByTime(
    reading contentKey: KeyPath<Element, String?>,
    writingTo assignKey: WritableKeyPath<Element, String?>
  ) -> [Element] {
    let grouped = Dictionary(grouping: self) { $0.time }
    let result = grouped.map { (_, records) -> Element in
      var base = records.first!
      
      let names = records.compactMap { $0[keyPath: contentKey] }
        .filter { !$0.isEmpty }
      
      let uniqueNames = Set(names).sorted()
      let mergedString = uniqueNames.joined(separator: "、")
      base[keyPath: assignKey] = mergedString
      return base
    }
    return result.sorted { $0.time < $1.time }
  }
}

#endif
