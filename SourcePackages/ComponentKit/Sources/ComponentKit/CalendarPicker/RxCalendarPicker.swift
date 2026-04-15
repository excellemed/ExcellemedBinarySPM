#if canImport(UIKit)

import UIKit

public nonisolated enum CalendarPickerEvent {
  case didSelect(Date, [CalendarEvent])
  case didScrollToDate(Date)
}

extension CalendarPicker: HasDelegate {
  public typealias Delegate = CalendarDelegate
}

@MainActor
class RxCalendarPickerDelegateProxy: DelegateProxy<CalendarPicker, CalendarDelegate>, DelegateProxyType {
  static func registerKnownImplementations() {
    register { RxCalendarPickerDelegateProxy($0) }
  }

  required init(_ parentObject: CalendarPicker) {
    super.init(
      parentObject: parentObject,
      delegateProxy: RxCalendarPickerDelegateProxy.self
    )
  }

  static func currentDelegate(for object: CalendarPicker) -> (any CalendarDelegate)? {
    object.delegate
  }

  static func setCurrentDelegate(_ delegate: (any CalendarDelegate)?, to object: CalendarPicker) {
    object.delegate = delegate
  }

  isolated deinit {
    subject.on(.completed)
  }

  fileprivate let subject = PublishRelay<CalendarPickerEvent>()
}

@MainActor
extension RxCalendarPickerDelegateProxy: CalendarDelegate {
  func calendar(_ calendar: CalendarPicker, didSelectDate date: Date, withEvents events: [CalendarEvent]) {
    subject.on(next: .didSelect(date, events))
  }

  func calendar(_ calendar: CalendarPicker, didScrollToMonth date: Date) {
    subject.on(next: .didScrollToDate(date))
  }
}
public extension Reactive where Base: CalendarPicker {
  @MainActor
  var response: Observable<CalendarPickerEvent> {
    RxCalendarPickerDelegateProxy.proxy(for: base).subject.eraseToAnyPublisher()
  }

  @MainActor
  var didSelectDate: Observable<CalendarPickerEvent> {
    response.filter {
      switch $0 {
      case .didSelect: true
      default: false
      }
    }
    .eraseToAnyPublisher()
  }

  @MainActor
  var didScrollToDate: Observable<CalendarPickerEvent> {
    response.filter {
      switch $0 {
      case .didScrollToDate: true
      default: false
      }
    }
    .eraseToAnyPublisher()
  }
}

#endif
