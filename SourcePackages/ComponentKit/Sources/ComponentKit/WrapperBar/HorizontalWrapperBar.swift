#if canImport(UIKit)

import UIKit
import Combine

/// **时间轴数据显示协议**
///
/// 任何需要在 `HorizontalWrapperBar` 中显示的数据模型都必须遵守此协议。
/// 组件仅依赖 `time` 属性来计算圆点在进度条上的位置。
///
/// **使用示例：**
/// ```swift
/// extension DietRecord: TimelineDataDisplayable {}
/// ```
public nonisolated protocol TimelineDataDisplayable: Codable {
  var time: TimeInterval { get }
  var id: String? { get }
}

/// 一个用于可视化单日事件分布的水平时间轴组件。
///
/// `HorizontalWrapperBar` 在水平轨道上绘制一系列圆点来表示事件发生的时间。
/// 组件左侧包含一个指示图标，右侧为时间轴轨道。它支持交互功能，用户点击圆点时可弹出气泡显示详情。
///
/// ## 布局注意事项
/// 由于此组件继承自 `UIView` 且未定义固有内容大小（Intrinsic Content Size），
/// **在使用 AutoLayout 时，必须显式指定高度约束（建议 28pt - 32pt）。**
///
/// ## 使用示例
///
/// ```swift
/// // 1. 初始化 (使用方形样式，圆角为 4)
/// let bar = HorizontalWrapperBar<MyRecord>(
///     icon: UIImage(named: "pill")!,
///     color: .systemBlue,
///     style: .square(4)
/// )
///
/// // 2. 添加到视图并布局
/// view.addSubview(bar)
/// bar.snp.makeConstraints { make in
///     make.left.right.equalToSuperview().inset(16)
///     make.height.equalTo(28) // 必须设置高度
/// }
///
/// // 3. 配置数据与交互
/// bar.range = 0...24
/// bar.data = myRecords
///
/// // 开启点击气泡交互
/// bar.textProvider = { record in
///     return "\(record.timeString): \(record.name)"
/// }
/// ```
public final class HorizontalWrapperBar<T: TimelineDataDisplayable>: UIView {
  
  /// 定义组件的视觉样式，主要影响背景条的形状和布局结构。
  public enum Style {
    /// 胶囊样式（默认）。
    ///
    /// 图标与时间轴包裹在同一个胶囊形背景中，整体感更强。
    case circle
    /// 方形（圆角矩形）样式。
    ///
    /// 图标与时间轴背景分离，图标独立显示在左侧，时间轴为圆角矩形。
    /// - Parameter radius: 背景条的圆角半径。
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
  
  public var range: ClosedRange<Int>? { didSet { setNeedsLayout() } }
  public var data: [T] = [] { didSet { setNeedsLayout() } }
  
  public var textProvider: ((T) -> String)? {
    didSet {
      isUserInteractionEnabled = textProvider != nil
      if textProvider != nil { setupGesture() }
    }
  }
  
  // MARK: - Init
  /// 创建一个新的水平时间轴组件。
  ///
  /// - Parameters:
  ///   - icon: 显示在组件最左侧的图标。
  ///     - Note: 无论选择何种样式，图标本身始终保持圆形显示。
  ///   - color: 主题颜色。将应用于图标背景、时间轴圆点颜色。
  ///   - style: 组件的布局样式，默认为 `.circle`。
  ///     - `.circle`: 图标包含在胶囊背景内。
  ///     - `.square(radius)`: 图标独立，背景条为指定圆角的矩形。
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
    let calendar = Calendar.current
    let now = Date()
    var components = calendar.dateComponents([.year, .month, .day], from: now)
    components.hour = lower; components.minute = 0; components.second = 0
    guard let startDate = calendar.date(from: components) else { return nil }
    let endDate: Date
    if upper == 24 {
      if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
         let nextStart = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow) {
        endDate = nextStart
      } else { return nil }
    } else {
      components.hour = upper
      guard let date = calendar.date(from: components) else { return nil }
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
      
      // 收集名字并过滤空值
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
