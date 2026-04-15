#if canImport(UIKit)

import UIKit
import ToolKit

public final class AreaSelectorHeader: UIScrollView {
  public enum Kind {
    case province
    case city
    case district
    case street
  }

  private let contentView = UIStackView()

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public var kind: Kind = .province {
    didSet {
      switch kind {
      case .province:
        province.isSelected = true
        city.isSelected = false
        district.isSelected = false
        street.isSelected = false
      case .city:
        province.isSelected = false
        city.isSelected = true
        district.isSelected = false
        street.isSelected = false
      case .district:
        province.isSelected = false
        city.isSelected = false
        district.isSelected = true
        street.isSelected = false
      case .street:
        province.isSelected = false
        city.isSelected = false
        district.isSelected = false
        street.isSelected = true
      }
    }
  }

  public lazy var province = UIButton()
  public lazy var city = UIButton()
  public lazy var district = UIButton()
  public lazy var street = UIButton()

  public init() {
    super.init(frame: .zero)
    setup()
  }

  public var provinceItem: Area? {
    didSet {
      province.setTitle(provinceItem?.name, for: .normal)
    }
  }

  public var cityItem: Area? {
    didSet {
      city.setTitle(cityItem?.name, for: .normal)
    }
  }

  public var districtItem: Area? {
    didSet {
      district.setTitle(districtItem?.name, for: .normal)
    }
  }

  public var streetItem: Area? {
    didSet {
      street.setTitle(streetItem?.name, for: .normal)
    }
  }

  private func setup() {
    isScrollEnabled = true
    showsVerticalScrollIndicator = false
    showsHorizontalScrollIndicator = false
    isPagingEnabled = false

    contentView.axis = .horizontal
    contentView.spacing = 25
    contentView.distribution = .fillProportionally
    contentView.alignment = .fill

    addSubview(contentView)
    contentView.addArrangedSubview(province)
    contentView.addArrangedSubview(city)
    contentView.addArrangedSubview(district)
    contentView.addArrangedSubview(street)

    contentView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
      contentView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
      contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
    ])

    province.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
    province.setTitleColor(.exBlack, for: .normal)
    province.setTitleColor(.init(hex: 0xF99141), for: .selected)

    city.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
    city.setTitleColor(.exBlack, for: .normal)
    city.setTitleColor(.init(hex: 0xF99141), for: .selected)

    district.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
    district.setTitleColor(.exBlack, for: .normal)
    district.setTitleColor(.init(hex: 0xF99141), for: .selected)

    street.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
    street.setTitleColor(.exBlack, for: .normal)
    street.setTitleColor(.init(hex: 0xF99141), for: .selected)
  }
}

final class UnderLineLabel: UILabel {
  public var underLineColor: UIColor = .init(hex: 0xF99141)

  private let insets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)

  override func drawText(in rect: CGRect) {
    super.drawText(in: rect.inset(by: insets))
  }

  override func draw(_ rect: CGRect) {
    super.draw(rect)
    let width = rect.width
    if let context = UIGraphicsGetCurrentContext() {
      context.setLineWidth(3)
      context.setLineCap(.round)
      let y = rect.height - 3
      context.move(to: CGPoint(x: width * 0.27, y: y))
      context.addLine(to: CGPoint(x: 0.73 * width, y: y))
      underLineColor.setStroke()
      context.strokePath()
    }
  }

  override var intrinsicContentSize: CGSize {
    let size = super.intrinsicContentSize
    return CGSize(
      width: size.width + insets.left + insets.right,
      height: size.height + insets.top + insets.bottom
    )
  }
}

public class AreaSelector: UIView {
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  public init() {
    super.init(frame: .zero)
    config()
    setup()
  }

  private let countryLabel = UnderLineLabel()

  public let header = AreaSelectorHeader()

  public let horizontalView = UIScrollView()

  private let horizontalContainer = UIStackView()
  public let provinceList = UITableView()
  public let cityList = UITableView()
  public let districtList = UITableView()
  public let streetList = UITableView()

  public static let ProvinceSection = "ProvinceSection"
  public static let CitySection = "CitySection"
  public static let DistrictSection = "DistrictSection"
  public static let StreetSection = "StreetSection"

  public static let ProvinceCell = "ProvinceCell"
  public static let CityCell = "CityCell"
  public static let DistrictCell = "DistrictCell"
  public static let StreetCell = "StreetCell"
}

extension AreaSelector {
  private func config() {
    horizontalView.isScrollEnabled = false
    horizontalView.isPagingEnabled = true
    horizontalView.showsHorizontalScrollIndicator = false
  }

  private func setup() {
    addSubview(countryLabel)
    addSubview(header)
    addSubview(horizontalView)

    horizontalView.addSubview(horizontalContainer)
    provinceList.separatorStyle = .none

    countryLabel.text = "中国大陆"
    countryLabel.font = .preferredFont(forTextStyle: .callout)
    countryLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      countryLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
      countryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
    ])

    header.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
      header.topAnchor.constraint(equalTo: countryLabel.bottomAnchor, constant: 20),
      header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
      header.heightAnchor.constraint(equalToConstant: 50),
    ])

    horizontalView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      horizontalView.leadingAnchor.constraint(equalTo: leadingAnchor),
      horizontalView.trailingAnchor.constraint(equalTo: trailingAnchor),
      horizontalView.topAnchor.constraint(equalTo: header.bottomAnchor),
      horizontalView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])

    horizontalContainer.addArrangedSubview(provinceList)
    horizontalContainer.addArrangedSubview(cityList)
    horizontalContainer.addArrangedSubview(districtList)
    horizontalContainer.addArrangedSubview(streetList)

    horizontalContainer.axis = .horizontal
    horizontalContainer.distribution = .fillEqually

    horizontalContainer.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      horizontalContainer.leadingAnchor.constraint(equalTo: horizontalView.leadingAnchor),
      horizontalContainer.trailingAnchor.constraint(equalTo: horizontalView.trailingAnchor),
      horizontalContainer.topAnchor.constraint(equalTo: horizontalView.topAnchor),
      horizontalContainer.bottomAnchor.constraint(equalTo: horizontalView.bottomAnchor),
      horizontalContainer.widthAnchor
        .constraint(
          equalTo: horizontalView.widthAnchor,
          multiplier: CGFloat(horizontalContainer.arrangedSubviews.count)
        ),
      horizontalContainer.heightAnchor.constraint(equalTo: horizontalView.heightAnchor),
    ])
  }
}

#endif
