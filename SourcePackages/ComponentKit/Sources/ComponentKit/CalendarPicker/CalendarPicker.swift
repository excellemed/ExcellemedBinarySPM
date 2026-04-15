#if canImport(UIKit)

import UIKit

public nonisolated struct EventLocation {
  let title: String
  let latitude: Double
  let longitude: Double
}

public nonisolated struct CalendarEvent {
  public let title: String
  public let startDate: Date
  public let endDate: Date
  public let isEnable: Bool

  public init(title: String, startDate: Date, endDate: Date, isEnable: Bool) {
    self.title = title
    self.startDate = startDate
    self.endDate = endDate
    self.isEnable = isEnable
  }
}

public nonisolated protocol CalendarDataSource {
  var startDate: Date { get }
  var endDate: Date { get }
  func headerString(_ date: Date) -> String?
}

public extension CalendarDataSource {
  var startDate: Date { Date() }
  var endDate: Date { Date() }

  func headerString(_ date: Date) -> String? { .none }
}

@MainActor
public protocol CalendarDelegate: AnyObject {
  func calendar(_ calendar: CalendarPicker, didScrollToMonth date: Date)
  func calendar(_ calendar: CalendarPicker, didSelectDate date: Date, withEvents events: [CalendarEvent])
  /* optional */
  func calendar(_ calendar: CalendarPicker, canSelectDate date: Date) -> Bool
  func calendar(_ calendar: CalendarPicker, didDeselectDate date: Date)
  func calendar(_ calendar: CalendarPicker, didLongPressDate date: Date, withEvents events: [CalendarEvent]?)
}

extension CalendarDelegate {
  func calendar(_ calendar: CalendarPicker, canSelectDate date: Date) -> Bool { true }
  func calendar(_ calendar: CalendarPicker, didDeselectDate date: Date) {}
  func calendar(_ calendar: CalendarPicker, didLongPressDate date: Date, withEvents events: [CalendarEvent]?) {}
}

public class CalendarPicker: UIView {
  public let kCalendarCellId = "CalendarDayCell"

  var headerView: CalendarHeaderView!
  var collectionView: UICollectionView!

  public var style: Style = .Default {
    didSet {
      updateStyle()
    }
  }

  public var calendar: Calendar {
    style.calendar
  }

  public internal(set) var selectedIndexPaths = [IndexPath]()
  public internal(set) var selectedDates: [Date] = []

  public var showSelectedDates: [Date] = [] {
    didSet {
      selectedDates = showSelectedDates
      selectDates(showSelectedDates)
    }
  }

  var _startDateCache: Date?
  var _endDateCache: Date?
  var _firstDayCache: Date?
  var _lastDayCache: Date?

  var todayIndexPath: IndexPath?
  var startIndexPath: IndexPath!
  var endIndexPath: IndexPath!

  var _cachedMonthInfoForSection = [Int: (firstDay: Int, daysTotal: Int)]()
  var eventsByIndexPath = [IndexPath: [CalendarEvent]]()

  public var events: [CalendarEvent] = [] {
    didSet {
      eventsByIndexPath.removeAll()

      for event in events {
        guard let indexPath = indexPathForDate(event.startDate) else { continue }

        var eventsForIndexPath = eventsByIndexPath[indexPath] ?? []
        eventsForIndexPath.append(event)
        eventsByIndexPath[indexPath] = eventsForIndexPath
      }

      DispatchQueue.main.async { self.collectionView.reloadData() }
    }
  }

  var flowLayout: CalendarFlowLayout {
    // swiftlint:disable force_cast
    collectionView.collectionViewLayout as! CalendarFlowLayout
    // swiftlint:enable force_cast
  }

  public internal(set) var displayDate: Date?

  public var showDate: Date? {
    didSet {
      if let showDate {
        setDisplayDate(showDate)
      }
    }
  }

  public var multipleSelectionEnable = false
  public var enableDeselection = false
  public var marksWeekends = false

  public var delegate: CalendarDelegate?
  public var dataSource: CalendarDataSource?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override public nonisolated func awakeFromNib() {
    super.awakeFromNib()
    MainActor.assumeIsolated {
      setup()
    }
  }

  private func setup() {
    clipsToBounds = true
    translatesAutoresizingMaskIntoConstraints = false
    headerView = CalendarHeaderView()
    headerView.style = style
    addSubview(headerView)
    headerView.translatesAutoresizingMaskIntoConstraints = false

    let layout = CalendarFlowLayout()
    layout.scrollDirection = .horizontal
    layout.sectionInset = UIEdgeInsets.zero
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0

    collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.isPagingEnabled = true
    collectionView.backgroundColor = UIColor.clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.allowsMultipleSelection = false
    collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: kCalendarCellId)
    addSubview(collectionView)
    collectionView.translatesAutoresizingMaskIntoConstraints = false

    if let superview = headerView.superview, case .some = collectionView.superview {
      NSLayoutConstraint.activate([
        headerView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
        headerView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
        headerView.topAnchor.constraint(equalTo: superview.topAnchor),
        headerView.heightAnchor.constraint(equalToConstant: style.headerHeight),
        collectionView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
        collectionView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
        collectionView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
        collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
      ])
    }

    headerView.leftArrow.ex.click = goToPreviousMonth
    headerView.rightArrow.ex.click = goToNextMonth
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    flowLayout.itemSize = cellSize(in: bounds)
    resetDisplayDate()
  }

  private func cellSize(in bounds: CGRect) -> CGSize {
    guard let collectionView
    else {
      return .zero
    }

    return CGSize(
      width: collectionView.bounds.width / 7.0,
      height: collectionView.bounds.height / 6.0
    )
  }

  func resetDisplayDate() {
    guard let displayDate else { return }

    collectionView.setContentOffset(
      scrollViewOffset(for: displayDate),
      animated: false
    )
  }

  func updateStyle() {
    headerView?.style = style
  }

  func scrollViewOffset(for date: Date) -> CGPoint {
    var point = CGPoint.zero
    guard let sections = indexPathForDate(date)?.section else { return point }
    point.x = CGFloat(sections) * collectionView.frame.width
    return point
  }
}

extension CalendarPicker {
  func indexPathForDate(_ date: Date) -> IndexPath? {
    let distanceFromStartDate = calendar.dateComponents([.month, .day], from: firstDayCache, to: date)

    guard
      let day = distanceFromStartDate.day,
      let month = distanceFromStartDate.month,
      let (firstDayIndex, _) = getCachedSectionInfo(month)
    else { return nil }

    return IndexPath(item: day + firstDayIndex, section: month)
  }

  func dateFromIndexPath(_ indexPath: IndexPath) -> Date? {
    let month = indexPath.section

    guard let monthInfo = getCachedSectionInfo(month) else { return nil }

    var components = DateComponents()
    components.month = month
    components.day = indexPath.item - monthInfo.firstDay

    return calendar.date(byAdding: components, to: firstDayCache)
  }
}

extension CalendarPicker {
  func goToMonthWithOffet(_ offset: Int) {
    guard let displayDate else { return }

    var dateComponents = DateComponents()
    dateComponents.month = offset

    guard let newDate = calendar.date(byAdding: dateComponents, to: displayDate) else { return }
    setDisplayDate(newDate, animated: true)
  }
}

public extension CalendarPicker {
  func reloadData() {
    collectionView.reloadData()
  }

  func setDisplayDate(_ date: Date, animated: Bool = false) {
    guard
      let startDate = calendar.dateInterval(of: .month, for: startDateCache)?.start,
      let endDate = calendar.dateInterval(of: .month, for: endDateCache)?.end,
      (startDate ..< endDate).contains(date)
    else {
      return
    }

    collectionView?.reloadData()
    collectionView?.setContentOffset(scrollViewOffset(for: date), animated: animated)
    displayDateOnHeader(date)
  }

  func selectDate(_ date: Date) {
    guard let indexPath = indexPathForDate(date) else { return }
    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition())
    collectionView(collectionView, didSelectItemAt: indexPath)
  }

  func selectDates(_ dates: [Date]) {
    dates.map { indexPathForDate($0) }
      .filter(\.isSome)
      .map { $0! }
      .forEach {
        collectionView.selectItem(at: $0, animated: false, scrollPosition: UICollectionView.ScrollPosition())
        collectionView(collectionView, didSelectItemAt: $0)
      }
  }

  func deselectDate(_ date: Date) {
    guard let indexPath = indexPathForDate(date) else { return }
    collectionView.deselectItem(at: indexPath, animated: false)
    collectionView(collectionView, didSelectItemAt: indexPath)
  }

  func goToNextMonth() {
    goToMonthWithOffet(1)
  }

  func goToPreviousMonth() {
    goToMonthWithOffet(-1)
  }

  func clearAllSelectedDates() {
    selectedIndexPaths.removeAll()
    selectedDates.removeAll()
    reloadData()
  }
}

#endif
