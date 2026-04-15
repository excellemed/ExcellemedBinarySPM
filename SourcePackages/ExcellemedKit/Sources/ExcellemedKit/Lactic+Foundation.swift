import Foundation

public enum LacticValueMode: Sendable {
  case normal
  case sport

  var divisor: Double { 10.0 }

  var clampUpperBound: Double {
    switch self {
    case .normal: 26.0
    case .sport: 41.0
    }
  }

  var displayUpperBound: Double {
    switch self {
    case .normal: 10.0
    case .sport: 40.0
    }
  }

  var warningThresholds: (normalMax: Double, lowMax: Double, highMax: Double) {
    switch self {
    case .normal: (2.2, 5.0, 10.0)
    case .sport: (3.0, 6.0, 40.0)
    }
  }
}

public enum LacticValueState: Sendable {
  case normal
  case low
  case high
  case tooHigh
}

public extension FoundationEx where T == UInt16 {
  nonisolated func toLacticValue(for mode: LacticValueMode) -> Double {
    let rawValue = Double(t) / mode.divisor
    return Swift.min(rawValue.rounded(to: 1), mode.clampUpperBound)
  }
}

public extension FoundationEx where T == Double {
  nonisolated func lacticState(for mode: LacticValueMode) -> LacticValueState {
    let thresholds = mode.warningThresholds
    if t < 0 {
      return .normal
    } else if t < thresholds.normalMax {
      return .normal
    } else if t < thresholds.lowMax {
      return .low
    } else if t <= thresholds.highMax {
      return .high
    } else {
      return .tooHigh
    }
  }

  nonisolated func formattedLacticValue(for mode: LacticValueMode) -> String {
    let lowerBound = 0.5
    switch t {
    case ..<lowerBound:
      return "≤\(lowerBound)"
    case lowerBound ... mode.displayUpperBound:
      return String(format: "%.1f", t)
    default:
      return "≥\(mode.displayUpperBound)"
    }
  }
}
