#if canImport(UIKit) && canImport(EventKit)

import EventKit
import UIKit

extension EKEvent {
  var isOneDay: Bool {
    let components = Calendar.current.dateComponents([.era, .year, .month, .day], from: startDate, to: endDate)
    return components.era == 0 && components.year == 0 && components.month == 0 && components.day == 0
  }
}

extension String {
  subscript(_ range: CountableRange<Int>) -> String {
    let start = index(startIndex, offsetBy: range.lowerBound)
    let end = index(startIndex, offsetBy: range.upperBound)
    return String(self[start ..< end])
  }
}

extension Date {
  func convertToTimeZone(from fromTimeZone: TimeZone, to toTimeZone: TimeZone) -> Date {
    let delta = TimeInterval(toTimeZone.secondsFromGMT(for: self) - fromTimeZone.secondsFromGMT(for: self))
    return addingTimeInterval(delta)
  }
}

#endif
