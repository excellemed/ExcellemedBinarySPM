#if canImport(UIKit)

import UIKit

extension CalendarPicker: UICollectionViewDataSource {
  func resetDateCaches() {
    _startDateCache = .none
    _endDateCache = .none

    _firstDayCache = .none
    _lastDayCache = .none

    _cachedMonthInfoForSection.removeAll()
  }

  var startDateCache: Date {
    if _startDateCache == .none {
      _startDateCache = dataSource?.startDate
    }

    return _startDateCache ?? Date()
  }

  var endDateCache: Date {
    if _endDateCache == .none {
      _endDateCache = dataSource?.endDate
    }

    return _endDateCache ?? Date()
  }

  var firstDayCache: Date {
    if _firstDayCache == .none {
      let startDateComponents = calendar.dateComponents([.era, .year, .month, .day], from: startDateCache)

      var firstDayOfStartMonthComponents = startDateComponents
      firstDayOfStartMonthComponents.day = 1

      let firstDayOfStartMonthDate = calendar.date(from: firstDayOfStartMonthComponents)!

      _firstDayCache = firstDayOfStartMonthDate
    }

    return _firstDayCache ?? Date()
  }

  var lastDayCache: Date {
    if _lastDayCache == .none {
      var lastDayOfEndMonthComponents = calendar.dateComponents([.era, .year, .month], from: endDateCache)
      let range = calendar.range(of: .day, in: .month, for: endDateCache)!
      lastDayOfEndMonthComponents.day = range.count

      _lastDayCache = calendar.date(from: lastDayOfEndMonthComponents)!
    }

    return _lastDayCache ?? Date()
  }

  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    guard dataSource != nil else { return 0 }

    if dataSource?.startDate != _startDateCache || dataSource?.endDate != _endDateCache {
      resetDateCaches()
    }

    guard startDateCache <= endDateCache else { fatalError("Start date cannot be later than end date.") }

    let startDateComponents = calendar.dateComponents([.era, .year, .month, .day], from: startDateCache)
    let endDateComponents = calendar.dateComponents([.era, .year, .month, .day], from: endDateCache)

    let local = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())!
    let today = Date().convertToTimeZone(from: calendar.timeZone, to: local)

    if (firstDayCache ... lastDayCache).contains(today) {
      let distanceFromTodayComponents = calendar.dateComponents([.month, .day], from: firstDayCache, to: today)

      todayIndexPath = IndexPath(item: distanceFromTodayComponents.day!, section: distanceFromTodayComponents.month!)
    }

    let numberOfMonths = calendar.dateComponents([.month], from: firstDayCache, to: lastDayCache).month!

    startIndexPath = IndexPath(item: startDateComponents.day! - 1, section: 0)
    endIndexPath = IndexPath(item: endDateComponents.day! - 1, section: numberOfMonths)

    return numberOfMonths + 1
  }

  public func getCachedSectionInfo(_ section: Int) -> (firstDay: Int, daysTotal: Int)? {
    if let result = _cachedMonthInfoForSection[section] {
      return result
    }

    var monthOffsetComponents = DateComponents()
    monthOffsetComponents.month = section

    let date = calendar.date(byAdding: monthOffsetComponents, to: firstDayCache)

    var firstWeekdayOfMonthIndex = date == .none ? 0 : calendar.component(.weekday, from: date!)
    firstWeekdayOfMonthIndex -= style.firstWeekday == .monday ? 1 : 0
    firstWeekdayOfMonthIndex = (firstWeekdayOfMonthIndex + 6) % 7  // push it modularly to map it in the range 0 to 6

    guard let rangeOfDaysInMonth = date == .none ? .none : calendar.range(of: .day, in: .month, for: date!)
    else { return .none }

    _cachedMonthInfoForSection[section] = (firstDay: firstWeekdayOfMonthIndex, daysTotal: rangeOfDaysInMonth.count)
    return _cachedMonthInfoForSection[section]
  }

  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    42
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    let dayCell =
      // swiftlint:disable force_cast
      collectionView.dequeueReusableCell(withReuseIdentifier: kCalendarCellId, for: indexPath) as! CalendarDayCell
    // swiftlint:enable force_cast

    dayCell.style = style
    dayCell.clearStyles()
    guard let (firstDayIndex, numberOfDaysTotal) = getCachedSectionInfo(indexPath.section) else { return dayCell }
    let lastDayIndex = firstDayIndex + numberOfDaysTotal

    let cellOutOfRange = { [unowned self] (indexPath: IndexPath) -> Bool in
      var isOutOfRange = false
      if startIndexPath.section == indexPath.section {
        isOutOfRange = startIndexPath.item + firstDayIndex > indexPath.item
      }
      if endIndexPath.section == indexPath.section, !isOutOfRange {
        isOutOfRange = endIndexPath.item + firstDayIndex < indexPath.item
      }
      return isOutOfRange
    }

    let isInRange = (firstDayIndex ..< lastDayIndex).contains(indexPath.item)
    let isAdjacent =
      !isInRange && style.showAdjacentDays && (indexPath.item < firstDayIndex || indexPath.item >= lastDayIndex)

    if isInRange || isAdjacent {
      dayCell.isHidden = false
      if isAdjacent {
        if indexPath.item < firstDayIndex {
          if let prevInfo = getCachedSectionInfo(indexPath.section - 1) {
            dayCell.day = prevInfo.daysTotal - firstDayIndex + indexPath.item
          } else {
            dayCell.isHidden = true
          }
        } else {
          dayCell.day = indexPath.item - lastDayIndex + 1
        }
      } else {
        dayCell.day = (indexPath.item - firstDayIndex) + 1
      }
      dayCell.isAdjacent = isAdjacent
      dayCell.isOutOfRange = cellOutOfRange(indexPath)
    } else {
      dayCell.isHidden = true
      dayCell.textLabel.text = ""
    }

    // 开始的时候调一次
    // if indexPath.section == 0, indexPath.item == 0 {
    // scrollViewDidEndDecelerating(collectionView)
    // }

    guard !dayCell.isOutOfRange else { return dayCell }

    if let idx = todayIndexPath {
      dayCell.isToday = (idx.section == indexPath.section && idx.item + firstDayIndex == indexPath.item)
    }

    dayCell.isPicked = selectedIndexPaths.contains(indexPath)

    if marksWeekends {
      let we = indexPath.item % 7
      let weekDayOption = style.firstWeekday == .sunday ? 0 : 5
      dayCell.isWeekend = we == weekDayOption || we == 6
    }

    dayCell.eventsCount = eventsByIndexPath[indexPath]?.count ?? 0

    return dayCell
  }
}

#endif
