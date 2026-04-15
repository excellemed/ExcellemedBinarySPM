#if os(iOS)

import UIKit

public final class TextField: UITextField {
  public override func textRect(forBounds bounds: CGRect) -> CGRect {
    bounds.insetBy(dx: 20, dy: 0)
  }
  public override func editingRect(forBounds bounds: CGRect) -> CGRect {
    bounds.insetBy(dx: 20, dy: 0)
  }
  public override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
    var rect = super.rightViewRect(forBounds: bounds)
    rect.origin.x -= 15
    return rect
  }
}

#endif
