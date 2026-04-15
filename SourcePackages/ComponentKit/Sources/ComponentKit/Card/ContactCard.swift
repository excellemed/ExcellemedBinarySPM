import UIKit

public class ContactCard: UIView {
  
  public var didTapCallHandler: (() -> Void)?
  
  
  private let containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 12
    view.layer.masksToBounds = true
    view.layer.borderWidth = 0.5
    view.layer.borderColor = UIColor.systemGray5.cgColor
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let headerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(hex: 0xF6F8FB)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let dateLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    label.textColor = UIColor.exBlack
    label.text = "创建时间：--"
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private let bodyView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let infoStack: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.alignment = .leading
    stack.spacing = 6
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()
  
  private let nameLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private let phoneLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
    label.textColor = UIColor.exBlack
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var callButton: UIButton = {
    let btn = UIButton(type: .custom)
    btn.backgroundColor = UIColor.exGreen
    btn.layer.cornerRadius = 10
    
    let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
    let image = UIImage(systemName: "phone.fill", withConfiguration: config)
    btn.setImage(image, for: .normal)
    btn.tintColor = .white
    
    btn.addTarget(self, action: #selector(handleCallTap), for: .touchUpInside)
    btn.translatesAutoresizingMaskIntoConstraints = false
    return btn
  }()
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupViews()
    setupConstraints()
  }
  
  private func setupViews() {
    addSubview(containerView)
    
    containerView.addSubview(headerView)
    headerView.addSubview(dateLabel)
    
    containerView.addSubview(bodyView)
    bodyView.addSubview(callButton)
    bodyView.addSubview(infoStack)
    
    infoStack.addArrangedSubview(nameLabel)
    infoStack.addArrangedSubview(phoneLabel)
  }
  
  private func setupConstraints() {
    let padding: CGFloat = 16.0
    
    NSLayoutConstraint.activate([
      containerView.topAnchor.constraint(equalTo: topAnchor),
      containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
      containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
      
      headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
      headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      
      dateLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
      dateLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10),
      dateLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: padding),
      
      bodyView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
      bodyView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      bodyView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      bodyView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      
      bodyView.heightAnchor.constraint(greaterThanOrEqualToConstant: 76),
      
      callButton.trailingAnchor.constraint(equalTo: bodyView.trailingAnchor, constant: -padding),
      callButton.centerYAnchor.constraint(equalTo: bodyView.centerYAnchor),
      callButton.widthAnchor.constraint(equalToConstant: 44),
      callButton.heightAnchor.constraint(equalToConstant: 44),
      
      infoStack.leadingAnchor.constraint(equalTo: bodyView.leadingAnchor, constant: padding),
      infoStack.centerYAnchor.constraint(equalTo: bodyView.centerYAnchor),
      infoStack.trailingAnchor.constraint(lessThanOrEqualTo: callButton.leadingAnchor, constant: -16)
    ])
  }
  
  @objc private func handleCallTap() {
    didTapCallHandler?()
  }
  
  
  /// - Parameters:
  ///   - date: 创建时间
  ///   - name: 姓名 (e.g. "王喜喜")
  ///   - phone: 手机号
  public func configure(date: String, name: String, phone: String) {
    dateLabel.text = "创建时间：\(date)"

    nameLabel.text = name
    
    phoneLabel.text = "手机号： \(phone)"
  }
}
