#if canImport(UIKit)

import UIKit

public final class SectionWithBottomLineBgView: UIView {
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
  }

  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    let (width, height) = (rect.width, rect.height)
    if let context = UIGraphicsGetCurrentContext() {
      UIColor(hex: 0xDEEBF4).setStroke()
      context.setLineWidth(1.0)
      context.move(to: CGPoint(x: 30, y: height - 1))
      context.addLine(to: CGPoint(x: width - 30, y: height - 1))
      context.strokePath()
    }
  }
}

final class SectionBgView: UIView {
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .init(hex: 0xFBFDFF)
  }
}

public final class SectionView: UITableViewHeaderFooterView {
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public let titleLabel = UILabel()

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    addSubview(titleLabel)
    titleLabel.font = .preferredFont(forTextStyle: .callout)
    titleLabel.textColor = .exDeepGray
    backgroundView = SectionBgView()
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    titleLabel.sizeToFit()
    titleLabel.frame.origin = CGPoint(x: 49.0, y: (frame.height - titleLabel.frame.height) * 0.5)
  }
}

public final class SectionWithBottomLineView: UITableViewHeaderFooterView {
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public let titleLabel = UILabel()

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    addSubview(titleLabel)
    titleLabel.font = .preferredFont(forTextStyle: .callout)
    titleLabel.textColor = .exBlack

    backgroundView = SectionWithBottomLineBgView()
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    titleLabel.sizeToFit()
    titleLabel.frame.origin = CGPoint(x: 30.0, y: (frame.height - titleLabel.frame.height) * 0.5)
  }
}

#endif
