#if canImport(UIKit)

import UIKit

public class Btn: UIButton {
  public nonisolated enum Kind {
    case cancel
    case confirm
    case red
    case add
  }

  public var title: String = "" {
    didSet {
      setNeedsUpdateConfiguration()
    }
  }
  var _kind: Kind
  public var kind: Kind {
    set {
      if _kind != newValue {
        _kind = newValue
        setNeedsUpdateConfiguration()
      }
    }
    get { _kind }
  }

  public init(
    title: String? = .none,
    isEnable: Bool = false,
    kind: Kind = .cancel,
    edges: NSDirectionalEdgeInsets? = .none
  ) {
    self._kind = kind
    super.init(frame: .zero)
    setup(edges)
    self.title = title ?? ""
    self.isEnabled = isEnable
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override var isEnabled: Bool {
    didSet {
      setNeedsUpdateConfiguration()
    }
  }
}

extension Btn {
  private func setup(_ edges: NSDirectionalEdgeInsets?) {
    var config = UIButton.Configuration.plain()
    config.cornerStyle = .capsule
    config.contentInsets = edges ?? NSDirectionalEdgeInsets(top: 13, leading: 0, bottom: 13, trailing: 0)
    config.background.strokeWidth = 2
    config.background.strokeOutset = 0
    setupConfigure()
    configuration = config
  }

  private func setupConfigure() {
    configurationUpdateHandler = { [unowned self] in
      if var config = $0.configuration {
        config.title = title
        if $0.isEnabled {
          let (backgroundColor, strokeColor, foregroundColor) =
            switch kind {
            case .cancel: (UIColor(hex: 0xFBFBFB), UIColor(hex: 0xDEEBF4), UIColor.exDeepGray)
            case .confirm: (UIColor.exBlue, UIColor.exBlue, UIColor.white)
            case .red: (UIColor.exRed, UIColor.exRed, UIColor.white)
            case .add: (UIColor(hex: 0xFBFBFB), UIColor(hex: 0xDEEBF4), UIColor.exBlack)
            }

          config.background.backgroundColor = backgroundColor
          config.background.strokeColor = strokeColor
          config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { container in
            var outgoing = container
            outgoing.font = UIFont.preferredFont(forTextStyle: .headline)
            outgoing.foregroundColor = foregroundColor
            return outgoing
          }
        } else {
          config.background.backgroundColor = UIColor(hex: 0xF6F8FB)
          config.background.strokeColor = UIColor(hex: 0xDEEBF4)
          config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { container in
            var outgoing = container
            outgoing.font = UIFont.preferredFont(forTextStyle: .headline)
            outgoing.foregroundColor = UIColor.exDeepGray
            return outgoing
          }
        }
        $0.configuration = config
      }
    }
  }
}

#endif
