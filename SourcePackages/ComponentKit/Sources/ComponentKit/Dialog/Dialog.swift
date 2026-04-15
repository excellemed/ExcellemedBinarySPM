#if canImport(UIKit)

import UIKit

open class DialogController: UIViewController {
  let contentView = UIView()
  public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    .portrait
  }
  public var subscriptions = Set<AnyCancellable>()
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public init() {
    super.init(nibName: .none, bundle: .none)
    modalPresentationStyle = .custom
    modalTransitionStyle = .crossDissolve
  }

  deinit {
    debugPrint("\(String(describing: Self.self)) deinit")
  }

  private func slideIn() {
    let animation = CABasicAnimation(keyPath: "position.y")
    animation.fromValue = view.frame.height + view.center.y
    animation.toValue = view.frame.height - view.center.y
    animation.duration = 0.3
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

    contentView.layer.add(animation, forKey: "slideIn")
  }

  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    slideIn()
  }

  private func slideOut() {
    let animation = CABasicAnimation(keyPath: "position.y")
    animation.fromValue = view.frame.height - view.center.y
    animation.toValue = view.frame.height + view.center.y
    animation.duration = 0.3
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

    contentView.layer.add(animation, forKey: "slideOut")
  }

  open override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    slideOut()
  }
}

public class DialogScreen: DialogController {
  private let titleLabelContainer = UIView()
  private lazy var titleLabel = UILabel()
  private lazy var subtitleLabel = UILabel()
  private lazy var btnGroup = UIStackView()
  public var mainTitle: String?
  public var subtitle: String?
  public var cancel: (() -> Void)?
  public var confirm: (() -> Void)?

  public lazy var confirmBtn = Btn(
    title: "确定",
    isEnable: true,
    kind: .confirm,
    edges: NSDirectionalEdgeInsets(top: 7, leading: 40, bottom: 7, trailing: 40)
  )
  public lazy var cancelBtn = Btn(
    title: "取消",
    isEnable: true,
    kind: .cancel,
    edges: NSDirectionalEdgeInsets(top: 7, leading: 40, bottom: 7, trailing: 40)
  )

  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(hex: 0x888888, alpha: 0.5)
    view.addSubview(contentView)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    if let superview = contentView.superview {
      NSLayoutConstraint.activate([
        contentView.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
        contentView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 27),
        contentView.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -27),
      ])
    }
    contentView.layer.cornerRadius = 20
    contentView.backgroundColor = .white
    contentView.addSubview(titleLabelContainer)
    titleLabelContainer.addSubview(titleLabel)
    titleLabelContainer.addSubview(subtitleLabel)
    contentView.addSubview(btnGroup)
    titleLabelContainer.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    btnGroup.translatesAutoresizingMaskIntoConstraints = false
    btnGroup.spacing = 20
    btnGroup.axis = .horizontal
    btnGroup.addArrangedSubview(cancelBtn)
    btnGroup.addArrangedSubview(confirmBtn)

    if let superview = titleLabelContainer.superview,
       let titleLabelSuperview = titleLabel.superview,
       let subtitleSuperview = subtitleLabel.superview,
       case .some = btnGroup.superview {
      NSLayoutConstraint.activate([
        titleLabelContainer.topAnchor.constraint(equalTo: superview.topAnchor, constant: 45),
        titleLabelContainer.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
        titleLabelContainer.trailingAnchor.constraint(equalTo: superview.trailingAnchor),

        titleLabel.topAnchor.constraint(equalTo: titleLabelSuperview.topAnchor),
        titleLabel.leadingAnchor.constraint(equalTo: titleLabelSuperview.leadingAnchor, constant: 40),
        titleLabel.trailingAnchor.constraint(equalTo: titleLabelSuperview.trailingAnchor, constant: -40),

        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
        subtitleLabel.leadingAnchor.constraint(equalTo: subtitleSuperview.leadingAnchor, constant: 40),
        subtitleLabel.trailingAnchor.constraint(equalTo: subtitleSuperview.trailingAnchor, constant: -40),
        subtitleLabel.bottomAnchor.constraint(equalTo: subtitleSuperview.bottomAnchor),

        btnGroup.topAnchor.constraint(equalTo: titleLabelContainer.bottomAnchor, constant: 20),
        btnGroup.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
        btnGroup.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -45),
      ])
    }

    titleLabel.text = mainTitle
    titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
    titleLabel.numberOfLines = 0

    subtitleLabel.text = subtitle
    subtitleLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
    subtitleLabel.textColor = UIColor.exDeepGray
    subtitleLabel.numberOfLines = 0

    cancelBtn.ex.click = cancel
    confirmBtn.ex.click = confirm
  }
}

#endif
