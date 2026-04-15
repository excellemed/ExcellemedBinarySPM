import UIKit

public enum BloodSugarState {
  case normal
  case low
  case high
  case tooHigh
  case unknown
}

extension BloodSugarState {
  public var color: UIColor {
    switch self {
    case .normal: .exBlack
    case .low: .exOrange
    case .high: .exRed
    case .tooHigh: .exRed
    case .unknown: .exRed
    }
  }

  public var monitorColor: UIColor {
    switch self {
    case .normal: .exBlue
    case .low: .exOrange
    case .high: .exRed
    case .tooHigh: .exRed
    case .unknown: .exRed
    }
  }

  public var hexColor: String {
    switch self {
    case .normal: "#01192B"
    case .low: "#F53953"
    case .high: "#F99141"
    case .tooHigh: "#F53953"
    case .unknown: "#F53953"
    }
  }
}

extension BloodSugarState: CustomStringConvertible {
  public var description: String {
    switch self {
    case .normal: "正常"
    case .low: "低血糖"
    case .high: "高血糖"
    case .tooHigh: "超监测范围"
    case .unknown: "血糖值异常"
    }
  }
}

extension FoundationEx where T == Double {
  public func calc(range: (Double, Double)) -> BloodSugarState {
    if t <= range.1 {
      if t == 0 {
        .unknown
      } else {
        .low
      }
    } else if t > range.1, t < range.0 {
      .normal
    } else if t >= range.0 {
      if t >= 40 {
        .tooHigh
      } else {
        .high
      }
    } else {
      .unknown
    }
  }
}
