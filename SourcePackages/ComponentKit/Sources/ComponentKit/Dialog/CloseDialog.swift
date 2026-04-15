#if canImport(UIKit)

import UIKit
import ToolKit

public class CloseDialogScreen: DialogController {
  private lazy var titleLabel = UILabel()
  private lazy var subtitleLabel = UILabel()
  private let subtitleLabelContainer = UILabel()
  
  public var mainTitle: String?
  public var subtitle: String?
  
  public var attributedSubtitle: NSAttributedString?
  public var subtitleColor: UIColor = .exDeepGray
  
  public var cancel: (() -> Void)?

  private lazy var cancelBtn = UIButton()

  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(hex: 0x888888, alpha: 0.5)
    view.addSubview(contentView)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.layer.cornerRadius = 20
    contentView.backgroundColor = .white
    
    if let superview = contentView.superview {
      NSLayoutConstraint.activate([
        contentView.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
        contentView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 27),
        contentView.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -27),
      ])
    }
    
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabelContainer.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(cancelBtn)
    contentView.addSubview(titleLabel)
    contentView.addSubview(subtitleLabelContainer)
    subtitleLabelContainer.addSubview(subtitleLabel)
    
    if let superview = titleLabel.superview, let subtitleSuperview = subtitleLabel.superview {
      
      NSLayoutConstraint.activate([
        titleLabel.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
        
        subtitleLabelContainer.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
        subtitleLabelContainer.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
        subtitleLabelContainer.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -45),
        
        subtitleLabel.leadingAnchor.constraint(equalTo: subtitleSuperview.leadingAnchor, constant: 40),
        subtitleLabel.trailingAnchor.constraint(equalTo: subtitleSuperview.trailingAnchor, constant: -40),
        subtitleLabel.topAnchor.constraint(equalTo: subtitleLabelContainer.topAnchor),
        subtitleLabel.bottomAnchor.constraint(equalTo: subtitleLabelContainer.bottomAnchor),
      ])
      
      if let title = mainTitle, !title.isEmpty {
        titleLabel.text = title
        titleLabel.isHidden = false
        
        NSLayoutConstraint.activate([
          titleLabel.topAnchor.constraint(equalTo: superview.topAnchor, constant: 45),
          subtitleLabelContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20)
        ])
      } else {
        titleLabel.text = nil
        titleLabel.isHidden = true
        
        NSLayoutConstraint.activate([
          subtitleLabelContainer.topAnchor.constraint(equalTo: superview.topAnchor, constant: 45)
        ])
      }
    }

    titleLabel.font = .preferredFont(forTextStyle: .headline)

    if let attributedText = attributedSubtitle {
        subtitleLabel.attributedText = attributedText
    } else {
        subtitleLabel.text = subtitle
        subtitleLabel.font = .preferredFont(forTextStyle: .headline)
        subtitleLabel.textColor = subtitleColor
    }
    subtitleLabel.numberOfLines = 0

    // 取消按钮布局
    cancelBtn.setImage(
      UIImage(from: IconFont.close, textColor: .white, backgroundColor: .clear, size: CGSize(width: 20, height: 20)),
      for: .normal
    )
    cancelBtn.translatesAutoresizingMaskIntoConstraints = false
    cancelBtn.layer.borderWidth = 2
    cancelBtn.layer.borderColor = UIColor.white.cgColor
    cancelBtn.layer.cornerRadius = 16
    if let superview = cancelBtn.superview {
      NSLayoutConstraint.activate([
        cancelBtn.widthAnchor.constraint(equalToConstant: 32),
        cancelBtn.heightAnchor.constraint(equalToConstant: 32),
        cancelBtn.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 20),
        cancelBtn.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
      ])
    }
    cancelBtn.ex.click = cancel
  }
}

#endif
