#if canImport(UIKit)

import UIKit

public extension CalendarPicker {
  public nonisolated enum CellShapeOptions {
    case round
    case square
    case bevel(CGFloat)
    var isRound: Bool {
      switch self {
      case .round: true
      default: false
      }
    }
  }

  public nonisolated enum FirstWeekdayOptions {
    case sunday
    case monday
  }

  public nonisolated enum WeekDaysTransform {
    case capitalized, uppercase
  }

  @MainActor
  final class Style {
    public static var Default: Style = .init()

    // Event
    public var cellEventColor = UIColor.exBlue

    // Header
    public var headerHeight: CGFloat = 80.0
    public var headerTopMargin: CGFloat = 5.0
    public var headerTextColor = UIColor.gray
    public var headerBackgroundColor = UIColor.white
    public var headerFont = UIFont.preferredFont(forTextStyle: .title3)

    public var weekdaysTopMargin: CGFloat = 3.0
    public var weekdaysBottomMargin: CGFloat = 3.0
    public var weekdaysHeight: CGFloat = 30.0
    public var weekdaysTextColor = UIColor.exBlack
    public var weekdaysBackgroundColor = UIColor.clear
    public var weekdaysFont = UIFont.preferredFont(forTextStyle: .footnote)

    // Common
    public var cellShape = CellShapeOptions.round

    public var firstWeekday = FirstWeekdayOptions.sunday
    public var showAdjacentDays = false

    // Default Style
    public var cellColorDefault = UIColor.clear
    public var cellTextColorDefault = UIColor(hex: 0x41638D)
    public var cellBorderColor = UIColor.clear
    public var cellBorderWidth = CGFloat(0.0)
    public var cellFont = UIFont.preferredFont(forTextStyle: .subheadline)

    // Today Style
    public var cellTextColorToday = UIColor(hex: 0x41638D)
    public var cellColorToday = UIColor.clear
    public var cellColorOutOfRange = UIColor.exLightGray
    public var cellColorAdjacent = UIColor.clear

    // Selected Style
    public var cellSelectedBorderColor = UIColor.exBlue
    public var cellSelectedBorderWidth: CGFloat = 2.0
    public var cellSelectedColor = UIColor.exBlue
    public var cellSelectedTextColor = UIColor.white

    // Weekend Style
    public var cellTextColorWeekend = UIColor.exBlack

    // Locale Style
    //    public var locale = Locale.autoupdatingCurrent
    public var locale = Locale(identifier: "zh_CN")

    public var dateFormat = "yyyy年MM月"

    // Calendar Identifier Style
    public lazy var calendar: Calendar = .current

    public var weekDayTransform = WeekDaysTransform.capitalized
  }
}

#endif
