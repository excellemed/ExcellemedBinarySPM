#if canImport(UIKit)

import UIKit
import ToolKit

public class LeftClose: UIButton {
  public init(iconColor: UIColor = .exLightGray) {
    super.init(frame: .zero)
    setImage(
      UIImage(from: .close, textColor: iconColor, size: CGSize(width: 24, height: 24)),
      for: .normal
    )
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

public class LeftArrow: UIButton {
  public static let DefaultSize = CGSize(width: 18, height: 18)
  public init(title: String? = "", isReverse: Bool = false, iconColor: UIColor = .exLightGray, size: CGSize = DefaultSize) {
    super.init(frame: .zero)
    var config = UIButton.Configuration.tinted()
    config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
    config.title = title
    config.baseBackgroundColor = .clear
    config.baseForegroundColor = UIColor.exBlack
    config.imagePadding = 14
    let attributedTitle = AttributedString(config.title ?? "", attributes: AttributeContainer([
      .font: UIFont.preferredFont(forTextStyle: .headline),
    ]))
    config.attributedTitle = attributedTitle
    if isReverse {
      config.image = UIImage(from: .leftArrow, textColor: iconColor, size: size).rotate(radians: .pi)
    } else {
      config.image = UIImage(from: .leftArrow, textColor: iconColor, size: size)
    }
    configuration = config
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

#endif
