#if canImport(UIKit)

import UIKit

extension CalendarPicker: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let date = dateFromIndexPath(indexPath) else { return }

    if let index = selectedIndexPaths.firstIndex(of: indexPath) {
      delegate?.calendar(self, didDeselectDate: date)
      if enableDeselection {
        // 反选时可能会超出 selectedIndexPaths 的范围造成 crash
        guard index < selectedIndexPaths.count, index < selectedDates.count else {
          return
        }
        selectedIndexPaths.remove(at: index)
        selectedDates.remove(at: index)
      }
    } else {
      guard let currentCell = collectionView.cellForItem(at: indexPath) as? CalendarDayCell else {
        selectedIndexPaths.append(indexPath)
        selectedDates.append(date)
        reloadData()
        return
      }

      if currentCell.isOutOfRange || currentCell.isAdjacent {
        reloadData()
        return
      }

      if !multipleSelectionEnable {
        selectedIndexPaths.removeAll()
        selectedDates.removeAll()
      }

      selectedIndexPaths.append(indexPath)
      selectedDates.append(date)
      currentCell.isPicked = true

      let eventsForDaySelected = eventsByIndexPath[indexPath] ?? []
      delegate?.calendar(self, didSelectDate: date, withEvents: eventsForDaySelected)
    }

    reloadData()
  }

  public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    guard let dateBeingSelected = dateFromIndexPath(indexPath) else { return false }

    if let delegate {
      return delegate.calendar(self, canSelectDate: dateBeingSelected)
    }

    return true
  }

  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    updateAndNotifyScrolling()
  }

  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    updateAndNotifyScrolling()
  }

  func updateAndNotifyScrolling() {
    guard let date = dateFromScrollViewPosition() else { return }

    displayDateOnHeader(date)
    delegate?.calendar(self, didScrollToMonth: date)
  }

  @discardableResult
  func dateFromScrollViewPosition() -> Date? {
    let offsetX = ceilf(Float(collectionView.contentOffset.x))
    let width = collectionView.bounds.size.width
    var page = max(Int(floor(offsetX / Float(width))), 0)
    var monthsOffsetComponents = DateComponents()
    monthsOffsetComponents.month = page
    return calendar.date(byAdding: monthsOffsetComponents, to: firstDayCache)
  }

  func displayDateOnHeader(_ date: Date) {
    headerView.monthLabel.text = dataSource?.headerString(date) ?? date.ex.stringify(style.dateFormat)
    displayDate = date
  }
}

#endif
