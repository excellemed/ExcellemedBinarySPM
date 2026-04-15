#if canImport(UIKit)

import UIKit

@MainActor
public protocol ModalPresenting: AnyObject {
  func showToast(text: String, position: ToastPosition)

  func uncheckedPresent(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)

  func uncheckedPresent(_ viewController: UIViewController, animated: Bool)

  func uncheckedPresent(_ viewController: UIViewController)

  func uncheckedPresent(_ viewController: UIViewController, completion: (() -> Void)?)

  func close(animated: Bool, completion: (() -> Void)?)

  var top: UIViewController? { get }

  func present(target: UIViewController, parent: UIViewController)

  func windowDismiss()
}

@MainActor
public final class ModalPresenter: ModalPresenting {
  public init() {}

  public func showToast(text: String, position: ToastPosition = .center) {
    if let top {
      top.view.makeToast(text, position: position)
    }
  }

  public func uncheckedPresent(
    _ viewController: UIViewController,
    animated: Bool,
    completion: (() -> Void)?
  ) {
    guard let top else {
      completion?()
      return
    }
    top.present(viewController, animated: animated, completion: completion)
  }

  public func uncheckedPresent(
    _ viewController: UIViewController
  ) {
    uncheckedPresent(viewController, animated: true, completion: .none)
  }

  public func uncheckedPresent(_ viewController: UIViewController, animated: Bool) {
    uncheckedPresent(viewController, animated: animated, completion: .none)
  }

  public func uncheckedPresent(_ viewController: UIViewController, completion: (() -> Void)? = .none) {
    uncheckedPresent(viewController, animated: true, completion: completion)
  }

  public func close(animated: Bool = true, completion: (() -> Void)? = .none) {
    guard let top else {
      completion?()
      return
    }
    top.dismiss(animated: animated, completion: completion)
  }

  public var top: UIViewController? {
    if let rootViewController = UIWindow.current?.rootViewController {
      return getTopViewController(from: rootViewController)
    }
    return .none
  }

  public func present(target: UIViewController, parent: UIViewController) {
    guard let scene = parent.view.window?.windowScene else { return }
    let newWindow = UIWindow(windowScene: scene)
    newWindow.rootViewController = target
    newWindow.windowLevel = .alert + 1
    newWindow.makeKeyAndVisible()
    window = newWindow
  }

  public func windowDismiss() {
    window?.isHidden = true
    window = .none
  }

  private var window: UIWindow?

  private func getTopViewController(from viewController: UIViewController) -> UIViewController {
    if let presentedViewController = viewController.presentedViewController {
      getTopViewController(from: presentedViewController)
    } else if let navigationController = viewController as? UINavigationController,
              let topViewController = navigationController.topViewController {
      getTopViewController(from: topViewController)
    } else if let tabBarController = viewController as? UITabBarController,
              let selectedViewController = tabBarController.selectedViewController {
      getTopViewController(from: selectedViewController)
    } else if let childViewController = viewController.children.last {
      getTopViewController(from: childViewController)
    } else {
      viewController
    }
  }
}

#endif
