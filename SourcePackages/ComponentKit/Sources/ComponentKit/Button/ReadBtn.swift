#if canImport(UIKit)

import UIKit

public final class ReadBtn: UIButton {
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  public var num = 0 {
    didSet {
      setNeedsUpdateConfiguration()
    }
  }
}

extension ReadBtn {
  func setup() {
    var config = UIButton.Configuration.plain()
    config.imagePadding = 5
    config.imagePlacement = .leading
    config.title = num == 0 ? " " : "(\(num))"
    let attributedTitle = AttributedString(config.title ?? "", attributes: AttributeContainer([
      .font: UIFont.preferredFont(forTextStyle: .subheadline),
      .foregroundColor: UIColor.exRed,
    ]))
    config.attributedTitle = attributedTitle
    config.image = UIImage.msg
    configuration = config
    configurationUpdateHandler = { [weak self] in
      guard let self, var cfg = $0.configuration else { return }
      cfg.title = num == 0 ? "" : "(\(num))"
      cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { container in
        var outgoing = container
        outgoing.font = UIFont.preferredFont(forTextStyle: .subheadline)
        outgoing.foregroundColor = UIColor.exRed
        return outgoing
      }
      configuration = cfg
    }
  }
}

#endif
