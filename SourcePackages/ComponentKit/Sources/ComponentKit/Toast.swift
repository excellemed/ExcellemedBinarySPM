#if os(iOS)

import ObjectiveC
import UIKit

public extension UIView {
  @MainActor
  private enum ToastKeys {
    static var timer = malloc(1)
    static var duration = malloc(1)
    static var point = malloc(1)
    static var completion = malloc(1)
    static var activeToasts = malloc(1)
    static var activityView = malloc(1)
    static var queue = malloc(1)
  }

  private class ToastCompletionWrapper {
    let completion: ((Bool) -> Void)?

    init(_ completion: ((Bool) -> Void)?) {
      self.completion = completion
    }
  }

  private enum ToastError: Error {
    case missingParameters
  }

  private var activeToasts: NSMutableArray {
    if let activeToasts = objc_getAssociatedObject(self, &ToastKeys.activeToasts) as? NSMutableArray {
      return activeToasts
    } else {
      let activeToasts = NSMutableArray()
      objc_setAssociatedObject(self, &ToastKeys.activeToasts, activeToasts, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return activeToasts
    }
  }

  private var queue: NSMutableArray {
    if let queue = objc_getAssociatedObject(self, &ToastKeys.queue) as? NSMutableArray {
      return queue
    } else {
      let queue = NSMutableArray()
      objc_setAssociatedObject(self, &ToastKeys.queue, queue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return queue
    }
  }

  func makeToast(
    _ message: String?,
    duration: TimeInterval? = nil,
    position: ToastPosition? = nil,
    title: String? = nil,
    image: UIImage? = nil,
    style: ToastStyle? = nil,
    completion: ((_ didTap: Bool) -> Void)? = nil
  ) {
    do {
      let resolvedStyle = style ?? ToastManager.shared.style
      let resolvedDuration = duration ?? ToastManager.shared.duration
      let resolvedPosition = position ?? ToastManager.shared.position
      let toast = try toastViewForMessage(message, title: title, image: image, style: resolvedStyle)
      showToast(toast, duration: resolvedDuration, position: resolvedPosition, completion: completion)
    } catch ToastError.missingParameters {
      print("Error: message, title, and image are all nil")
    } catch {}
  }

  func makeToast(
    _ message: String?,
    duration: TimeInterval? = nil,
    point: CGPoint,
    title: String?,
    image: UIImage?,
    style: ToastStyle? = nil,
    completion: ((_ didTap: Bool) -> Void)?
  ) {
    do {
      let resolvedStyle = style ?? ToastManager.shared.style
      let resolvedDuration = duration ?? ToastManager.shared.duration
      let toast = try toastViewForMessage(message, title: title, image: image, style: resolvedStyle)
      showToast(toast, duration: resolvedDuration, point: point, completion: completion)
    } catch ToastError.missingParameters {
      print("Error: message, title, and image cannot all be nil")
    } catch {}
  }

  func showToast(
    _ toast: UIView,
    duration: TimeInterval? = nil,
    position: ToastPosition? = nil,
    completion: ((_ didTap: Bool) -> Void)? = nil
  ) {
    let resolvedDuration = duration ?? ToastManager.shared.duration
    let resolvedPosition = position ?? ToastManager.shared.position
    let point = resolvedPosition.centerPoint(forToast: toast, inSuperview: self)
    showToast(toast, duration: resolvedDuration, point: point, completion: completion)
  }

  func showToast(
    _ toast: UIView,
    duration: TimeInterval? = nil,
    point: CGPoint,
    completion: ((_ didTap: Bool) -> Void)? = nil
  ) {
    let resolvedDuration = duration ?? ToastManager.shared.duration
    objc_setAssociatedObject(
      toast,
      &ToastKeys.completion,
      ToastCompletionWrapper(completion),
      .OBJC_ASSOCIATION_RETAIN_NONATOMIC
    )

    if ToastManager.shared.isQueueEnabled, activeToasts.count > 0 {
      objc_setAssociatedObject(
        toast,
        &ToastKeys.duration,
        NSNumber(value: resolvedDuration),
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
      objc_setAssociatedObject(toast, &ToastKeys.point, NSValue(cgPoint: point), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

      queue.add(toast)
    } else {
      showToast(toast, duration: resolvedDuration, point: point)
    }
  }

  func showToastActivity(_ toast: UIView, position: ToastPosition? = nil) {
    let resolvePosition = position ?? ToastManager.shared.position
    guard objc_getAssociatedObject(self, &ToastKeys.activityView) as? UIView == nil else { return }
    let point = resolvePosition.centerPoint(forToast: toast, inSuperview: self)
    makeToastActivity(toast, point: point)
  }

  func hideToast() {
    guard let activeToast = activeToasts.firstObject as? UIView else { return }
    hideToast(activeToast)
  }

  func hideToast(_ toast: UIView) {
    guard activeToasts.contains(toast) else { return }
    hideToast(toast, fromTap: false)
  }

  func hideAllToasts(includeActivity: Bool = false, clearQueue: Bool = true) {
    if clearQueue {
      clearToastQueue()
    }

    activeToasts.compactMap { $0 as? UIView }
      .forEach { hideToast($0) }

    if includeActivity {
      hideToastActivity()
    }
  }

  func clearToastQueue() {
    queue.removeAllObjects()
  }

  func makeToastActivity(_ position: ToastPosition) {
    guard objc_getAssociatedObject(self, &ToastKeys.activityView) as? UIView == nil else { return }

    let toast = createToastActivityView()
    let point = position.centerPoint(forToast: toast, inSuperview: self)
    makeToastActivity(toast, point: point)
  }

  func makeToastActivity(_ point: CGPoint) {
    guard objc_getAssociatedObject(self, &ToastKeys.activityView) as? UIView == nil else { return }

    let toast = createToastActivityView()
    makeToastActivity(toast, point: point)
  }

  func hideToastActivity() {
    if let toast = objc_getAssociatedObject(self, &ToastKeys.activityView) as? UIView {
      UIView.animate(
        withDuration: ToastManager.shared.style.fadeDuration,
        delay: 0.0,
        options: [.curveEaseIn, .beginFromCurrentState],
        animations: {
          toast.alpha = 0.0
        }
      ) { _ in
        toast.removeFromSuperview()
        objc_setAssociatedObject(self, &ToastKeys.activityView, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      }
    }
  }

  func isShowingToast() -> Bool {
    activeToasts.count > 0 || objc_getAssociatedObject(self, &ToastKeys.activityView) != nil
  }

  private func makeToastActivity(_ toast: UIView, point: CGPoint) {
    toast.alpha = 0.0
    toast.center = point

    objc_setAssociatedObject(self, &ToastKeys.activityView, toast, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

    addSubview(toast)

    UIView.animate(
      withDuration: ToastManager.shared.style.fadeDuration,
      delay: 0.0,
      options: .curveEaseOut,
      animations: {
        toast.alpha = 1.0
      }
    )
  }

  private func createToastActivityView() -> UIView {
    let style = ToastManager.shared.style

    let activityView = UIView(
      frame: CGRect(x: 0.0, y: 0.0, width: style.activitySize.width, height: style.activitySize.height)
    )
    activityView.backgroundColor = style.activityBackgroundColor
    activityView.autoresizingMask = [
      .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin,
    ]
    activityView.layer.cornerRadius = style.cornerRadius

    if style.displayShadow {
      activityView.layer.shadowColor = style.shadowColor.cgColor
      activityView.layer.shadowOpacity = style.shadowOpacity
      activityView.layer.shadowRadius = style.shadowRadius
      activityView.layer.shadowOffset = style.shadowOffset
    }

    let activityIndicatorView = LottieActivityIndicator()
    activityIndicatorView.center = CGPoint(
      x: activityView.bounds.size.width / 2.0,
      y: activityView.bounds.size.height / 2.0
    )
    activityView.addSubview(activityIndicatorView)
    activityIndicatorView.startAnimating()

    return activityView
  }

  private func showToast(_ toast: UIView, duration: TimeInterval, point: CGPoint) {
    toast.center = point
    toast.alpha = 0.0

    if ToastManager.shared.isTapToDismissEnabled {
      let recognizer = UITapGestureRecognizer(target: self, action: #selector(UIView.handleToastTapped(_:)))
      toast.addGestureRecognizer(recognizer)
      toast.isUserInteractionEnabled = true
      toast.isExclusiveTouch = true
    }

    activeToasts.add(toast)
    addSubview(toast)

    let timer = Timer(
      timeInterval: duration,
      target: self,
      selector: #selector(UIView.toastTimerDidFinish(_:)),
      userInfo: toast,
      repeats: false
    )
    objc_setAssociatedObject(toast, &ToastKeys.timer, timer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

    UIView.animate(
      withDuration: ToastManager.shared.style.fadeDuration,
      delay: 0.0,
      options: [.curveEaseOut, .allowUserInteraction],
      animations: {
        toast.alpha = 1.0
      }
    ) { _ in
      guard let timer = objc_getAssociatedObject(toast, &ToastKeys.timer) as? Timer else { return }
      RunLoop.main.add(timer, forMode: .common)
    }

    UIAccessibility.post(notification: .screenChanged, argument: toast)
  }

  private func hideToast(_ toast: UIView, fromTap: Bool) {
    if let timer = objc_getAssociatedObject(toast, &ToastKeys.timer) as? Timer {
      timer.invalidate()
    }

    UIView.animate(
      withDuration: ToastManager.shared.style.fadeDuration,
      delay: 0.0,
      options: [.curveEaseIn, .beginFromCurrentState],
      animations: {
        toast.alpha = 0.0
      }
    ) { _ in
      toast.removeFromSuperview()
      self.activeToasts.remove(toast)

      if let wrapper = objc_getAssociatedObject(toast, &ToastKeys.completion) as? ToastCompletionWrapper,
        let completion = wrapper.completion
      {
        completion(fromTap)
      }

      if let nextToast = self.queue.firstObject as? UIView,
        let duration = objc_getAssociatedObject(nextToast, &ToastKeys.duration) as? NSNumber,
        let point = objc_getAssociatedObject(nextToast, &ToastKeys.point) as? NSValue
      {
        self.queue.removeObject(at: 0)
        self.showToast(nextToast, duration: duration.doubleValue, point: point.cgPointValue)
      }
    }
  }

  @objc
  private func handleToastTapped(_ recognizer: UITapGestureRecognizer) {
    guard let toast = recognizer.view else { return }
    hideToast(toast, fromTap: true)
  }

  @objc
  private func toastTimerDidFinish(_ timer: Timer) {
    guard let toast = timer.userInfo as? UIView else { return }
    hideToast(toast)
  }

  func toastViewForMessage(_ message: String?, title: String?, image: UIImage?, style: ToastStyle) throws -> UIView {
    guard message != nil || title != nil || image != nil else {
      throw ToastError.missingParameters
    }

    var messageLabel: UILabel?
    var titleLabel: UILabel?
    var imageView: UIImageView?

    let wrapperView = UIView()
    wrapperView.backgroundColor = style.backgroundColor
    wrapperView.autoresizingMask = [
      .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin,
    ]
    wrapperView.layer.cornerRadius = style.cornerRadius

    if style.displayShadow {
      wrapperView.layer.shadowColor = style.shadowColor.cgColor
      wrapperView.layer.shadowOpacity = style.shadowOpacity
      wrapperView.layer.shadowRadius = style.shadowRadius
      wrapperView.layer.shadowOffset = style.shadowOffset
    }

    if let image {
      imageView = UIImageView(image: image)
      imageView?.contentMode = .scaleAspectFit
      imageView?.frame = CGRect(
        x: style.horizontalPadding,
        y: style.verticalPadding,
        width: style.imageSize.width,
        height: style.imageSize.height
      )
    }

    var imageRect = CGRect.zero

    if let imageView {
      imageRect.origin.x = style.horizontalPadding
      imageRect.origin.y = style.verticalPadding
      imageRect.size.width = imageView.bounds.size.width
      imageRect.size.height = imageView.bounds.size.height
    }

    if let title {
      titleLabel = UILabel()
      titleLabel?.numberOfLines = style.titleNumberOfLines
      titleLabel?.font = style.titleFont
      titleLabel?.textAlignment = style.titleAlignment
      titleLabel?.lineBreakMode = .byTruncatingTail
      titleLabel?.textColor = style.titleColor
      titleLabel?.backgroundColor = UIColor.clear
      titleLabel?.text = title

      let maxTitleSize = CGSize(
        width: (bounds.size.width * style.maxWidthPercentage) - imageRect.size.width,
        height: bounds.size.height * style.maxHeightPercentage
      )
      let titleSize = titleLabel?.sizeThatFits(maxTitleSize)
      if let titleSize {
        titleLabel?.frame = CGRect(x: 0.0, y: 0.0, width: titleSize.width, height: titleSize.height)
      }
    }

    if let message {
      messageLabel = UILabel()
      messageLabel?.text = message
      messageLabel?.numberOfLines = style.messageNumberOfLines
      messageLabel?.font = style.messageFont
      messageLabel?.textAlignment = style.messageAlignment
      messageLabel?.lineBreakMode = .byTruncatingTail
      messageLabel?.textColor = style.messageColor
      messageLabel?.backgroundColor = UIColor.clear

      let maxMessageSize = CGSize(
        width: (bounds.size.width * style.maxWidthPercentage) - imageRect.size.width,
        height: bounds.size.height * style.maxHeightPercentage
      )
      let messageSize = messageLabel?.sizeThatFits(maxMessageSize)
      if let messageSize {
        let actualWidth = min(messageSize.width, maxMessageSize.width)
        let actualHeight = min(messageSize.height, maxMessageSize.height)
        messageLabel?.frame = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
      }
    }

    var titleRect = CGRect.zero

    if let titleLabel {
      titleRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding
      titleRect.origin.y = style.verticalPadding
      titleRect.size.width = titleLabel.bounds.size.width
      titleRect.size.height = titleLabel.bounds.size.height
    }

    var messageRect = CGRect.zero

    if let messageLabel {
      messageRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding
      messageRect.origin.y = titleRect.origin.y + titleRect.size.height + style.verticalPadding
      messageRect.size.width = messageLabel.bounds.size.width
      messageRect.size.height = messageLabel.bounds.size.height
    }

    let longerWidth = max(titleRect.size.width, messageRect.size.width)
    let longerX = max(titleRect.origin.x, messageRect.origin.x)
    let wrapperWidth = max(
      imageRect.size.width + (style.horizontalPadding * 2.0),
      longerX + longerWidth + style.horizontalPadding
    )

    let textMaxY = messageRect.size.height <= 0.0 && titleRect.size.height > 0.0 ? titleRect.maxY : messageRect.maxY
    let wrapperHeight = max(textMaxY + style.verticalPadding, imageRect.size.height + (style.verticalPadding * 2.0))

    wrapperView.frame = CGRect(x: 0.0, y: 0.0, width: wrapperWidth, height: wrapperHeight)

    if let titleLabel {
      titleRect.size.width = longerWidth
      titleLabel.frame = titleRect
      wrapperView.addSubview(titleLabel)
    }

    if let messageLabel {
      messageRect.size.width = longerWidth
      messageLabel.frame = messageRect
      wrapperView.addSubview(messageLabel)
    }

    if let imageView {
      wrapperView.addSubview(imageView)
    }

    return wrapperView
  }
}

public struct ToastStyle {
  public init() {}

  public var backgroundColor: UIColor = .init(hex: 0xF6F8FB)

  public var titleColor: UIColor = .init(hex: 0x7F9CC0)

  public var messageColor: UIColor = .init(hex: 0x7F9CC0)

  public var maxWidthPercentage: CGFloat = 0.8 {
    didSet {
      maxWidthPercentage = max(min(maxWidthPercentage, 1.0), 0.0)
    }
  }

  public var maxHeightPercentage: CGFloat = 0.8 {
    didSet {
      maxHeightPercentage = max(min(maxHeightPercentage, 1.0), 0.0)
    }
  }

  public var horizontalPadding: CGFloat = 10.0

  public var verticalPadding: CGFloat = 10.0

  public var cornerRadius: CGFloat = 10.0

  public var titleFont: UIFont = .boldSystemFont(ofSize: 16.0)

  public var messageFont: UIFont = .preferredFont(forTextStyle: .subheadline)

  public var titleAlignment: NSTextAlignment = .left

  public var messageAlignment: NSTextAlignment = .left

  public var titleNumberOfLines = 0

  public var messageNumberOfLines = 0

  public var displayShadow = false

  public var shadowColor: UIColor = .black

  public var shadowOpacity: Float = 0.8 {
    didSet {
      shadowOpacity = max(min(shadowOpacity, 1.0), 0.0)
    }
  }

  public var shadowRadius: CGFloat = 6.0

  public var shadowOffset = CGSize(width: 4.0, height: 4.0)

  public var imageSize = CGSize(width: 80.0, height: 80.0)

  public var activitySize = CGSize(width: 100.0, height: 100.0)

  public var fadeDuration: TimeInterval = 0.2

  public var activityIndicatorColor: UIColor = .white

  public var activityBackgroundColor: UIColor = .init(hex: 0xF6F8FB)
}

@MainActor
public class ToastManager {
  @MainActor public static let shared = ToastManager()

  public var style = ToastStyle()

  public var isTapToDismissEnabled = true

  public var isQueueEnabled = false

  public var duration: TimeInterval = 3.0

  public var position: ToastPosition = .bottom
}

@MainActor
public enum ToastPosition {
  case top
  case center
  case bottom

  fileprivate func centerPoint(forToast toast: UIView, inSuperview superview: UIView) -> CGPoint {
    let topPadding: CGFloat = ToastManager.shared.style.verticalPadding + superview.safeAreaInsets.top
    let bottomPadding: CGFloat = ToastManager.shared.style.verticalPadding + superview.safeAreaInsets.bottom

    return switch self {
    case .top:
      CGPoint(x: superview.bounds.size.width / 2.0, y: (toast.frame.size.height / 2.0) + topPadding)
    case .center:
      CGPoint(x: superview.bounds.size.width / 2.0, y: superview.bounds.size.height / 2.0)
    case .bottom:
      CGPoint(
        x: superview.bounds.size.width / 2.0,
        y: (superview.bounds.size.height - (toast.frame.size.height / 2.0)) - bottomPadding
      )
    }
  }
}

#endif
