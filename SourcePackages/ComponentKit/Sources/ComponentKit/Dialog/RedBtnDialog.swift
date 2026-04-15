#if canImport(UIKit)

import UIKit

public class RedBtnDialogScreen: DialogController {
  private lazy var titleLabel = UILabel()
  private lazy var subtitleLabel = UILabel()
  
  lazy var confirmBtn = Btn(
    title: confirmStr,
    kind: .red,
    edges: NSDirectionalEdgeInsets(top: 7, leading: 60, bottom: 7, trailing: 60)
  )
  private lazy var cancelBtn = UIButton()
  
  public var mainTitle: String?
  public var subtitle: String?
  public var confirmStr: String?
  public var cancelStr: String?
  public var cancel: (() -> Void)?
  public var confirm: (() -> Void)?
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(hex: 0x888888, alpha: 0.5)
    view.addSubview(contentView)
    
    contentView.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    confirmBtn.translatesAutoresizingMaskIntoConstraints = false
    cancelBtn.translatesAutoresizingMaskIntoConstraints = false
    
    contentView.backgroundColor = .white
    contentView.layer.cornerRadius = 20
    
    contentView.addSubview(titleLabel)
    contentView.addSubview(subtitleLabel)
    contentView.addSubview(confirmBtn)
    contentView.addSubview(cancelBtn)
    
    NSLayoutConstraint.activate([
      contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
      contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
      contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
      titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 20),
      titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
      
      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
      subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
      subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
      
      confirmBtn.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
      confirmBtn.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      
      cancelBtn.topAnchor.constraint(equalTo: confirmBtn.bottomAnchor, constant: 14),
      cancelBtn.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      
      cancelBtn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
    ])
    
    confirmBtn.isEnabled = true
    
    confirmBtn.setTitle(confirmStr, for: .normal)
    
    cancelBtn.setTitle(cancelStr, for: .normal)
    cancelBtn.setTitleColor(.exDeepGray, for: .normal)
    cancelBtn.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
    
    titleLabel.text = mainTitle
    titleLabel.font = .preferredFont(forTextStyle: .headline)
    
    subtitleLabel.text = subtitle
    subtitleLabel.font = .preferredFont(forTextStyle: .footnote)
    subtitleLabel.textColor = UIColor.exBlack
    subtitleLabel.numberOfLines = 0
    subtitleLabel.textAlignment = .center
    
    confirmBtn.ex.click = confirm
    cancelBtn.ex.click = cancel
  }
}

#endif
