import UIKit

class MutableColorIcon: UIView {
  let imageView = UIImageView()

  override var backgroundColor: UIColor? {
    didSet {
      setNeedsDisplay()
    }
  }

  init(_ image: UIImage) {
    super.init(frame: CGRectMake(0, 0, 20, 20))
    layer.cornerRadius = 10
    imageView.image = image
    addSubview(imageView)
    imageView.frame = CGRectMake(0, 0, bounds.width * 0.5, bounds.height * 0.5)
    imageView.center = center
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

final class MutableColorDot: UIView {
  override var backgroundColor: UIColor? {
    didSet {
      setNeedsDisplay()
    }
  }

  init(_ color: UIColor) {
    super.init(frame: CGRectMake(0, 0, 8, 8))
    self.backgroundColor = color
    layer.cornerRadius = 4
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
