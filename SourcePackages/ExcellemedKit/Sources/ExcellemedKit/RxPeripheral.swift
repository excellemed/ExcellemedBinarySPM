extension Peripheral: @retroactive HasDelegate {
  public typealias Delegate = PeripheralDelegate
}

extension PublishSubject: @unchecked @retroactive Sendable {}

@MainActor
final class RxPeripheralDelegateProxy: DelegateProxy<Peripheral, PeripheralDelegate>, DelegateProxyType,
  PeripheralDelegate
{
  fileprivate let subject = PublishRelay<Peripheral.Event>()

  required init(_ peripheral: Peripheral) {
    super.init(parentObject: peripheral, delegateProxy: RxPeripheralDelegateProxy.self)
  }

  static func currentDelegate(for object: Peripheral) -> (any PeripheralDelegate)? {
    object.delegate
  }

  static func setCurrentDelegate(_ delegate: (any PeripheralDelegate)?, to object: Peripheral) {
    object.delegate = delegate
  }

  static func registerKnownImplementations() {
    register { RxPeripheralDelegateProxy($0) }
  }

  nonisolated func peripheral(
    _ peripheral: Peripheral,
    didUpdateValueFor characteristic: CBCharacteristic,
    error: (any Error)?
  ) {
    subject.on(next: .didUpdateValueFor(characteristic, error))
  }

  deinit {
    subject.on(.completed)
  }
}

@MainActor
public extension Reactive where Base: Peripheral {
  var response: Observable<Peripheral.Event> {
    RxPeripheralDelegateProxy.proxy(for: base).subject.eraseToAnyPublisher()
  }

  var notify: Observable<Peripheral.Event> {
    response.filter {
      switch $0 {
      case .didUpdateValueFor: true
      default: false
      }
    }
    .eraseToAnyPublisher()
  }
}
