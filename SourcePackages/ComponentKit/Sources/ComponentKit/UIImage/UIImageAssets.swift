#if canImport(UIKit)

import UIKit

extension UIImage {
  static var EditCancel: UIImage {
    UIImage(named: "edit-cancel", in: .module, compatibleWith: .none)!
  }

  static var Checked: UIImage {
    UIImage(named: "checked", in: .module, compatibleWith: .none)!
  }
  
  static var msg: UIImage {
    UIImage(named: "msg", in: .module, compatibleWith: .none)!
  }
}

#endif
