import UIKit

public final class LoadingCheckbox: Checkbox {
  public enum VisualState: Equatable {
    case unchecked
    case checked
    case loading
  }

  private let indicator = LoadingCheckboxActivityIndicator()

  public var visualState: VisualState = .unchecked {
    didSet {
      applyVisualState(animated: oldValue != visualState)
    }
  }

  public override init() {
    super.init()
    setupIndicator()
    applyVisualState(animated: false)
  }
  
  public convenience init(shape: any CheckboxShape) {
    self.init()
    self.shape = shape
    setupIndicator()
    applyVisualState(animated: false)
  }

  private func setupIndicator() {
    indicator.isUserInteractionEnabled = false
    addSubview(indicator)
  }

  private func applyVisualState(animated: Bool) {
    switch visualState {
    case .unchecked:
      hideCheckboxLayers(false)
      indicator.stopAnimating()
      super.setChecked(false, animated: animated)
    case .checked:
      hideCheckboxLayers(false)
      indicator.stopAnimating()
      super.setChecked(true, animated: animated)
    case .loading:
      hideCheckboxLayers(true)
      indicator.startAnimating()
    }
  }

  private func hideCheckboxLayers(_ hidden: Bool) {
    layer.sublayers?.forEach { sublayer in
      guard sublayer !== indicator.layer else { return }
      sublayer.isHidden = hidden
    }
  }

  public override func setChecked(_ checked: Bool, animated: Bool) {
    visualState = checked ? .checked : .unchecked
  }

  public override var isChecked: Bool {
    get { visualState == .checked }
    set { visualState = newValue ? .checked : .unchecked }
  }

  public override var isCheckedNoAnimation: Bool {
    get { visualState == .checked }
    set {
      let previousState = visualState
      visualState = newValue ? .checked : .unchecked
      if previousState != visualState {
        applyVisualState(animated: false)
      }
    }
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    let side = min(bounds.width, bounds.height)
    indicator.frame = CGRect(
      x: (bounds.width - side) / 2,
      y: (bounds.height - side) / 2,
      width: side,
      height: side
    )
  }
}

extension Reactive where Base: LoadingCheckbox {
  public var visualState: Binder<LoadingCheckbox.VisualState> {
    Binder(base) { v, state in
      v.visualState = state
    }
  }
}
