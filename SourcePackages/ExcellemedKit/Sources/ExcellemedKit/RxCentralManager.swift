extension CentralManager: @retroactive HasDelegate {
  public typealias Delegate = CentralManagerDelegate
}

final class CombineCentralManagerDelegateProxy: DelegateProxy<
  CentralManager,
  CentralManagerDelegate
>,
DelegateProxyType,
CentralManagerDelegate
{
  nonisolated func centralManager(
    _ central: BLEKit.CentralManager,
    didUpdateANCSAuthorizationFor peripheral: BLEKit.Peripheral
  ) {
  }

  nonisolated func centralManager(
    _ central: CentralManager,
    connectionEventDidOccur event: CBConnectionEvent,
    for peripheral: Peripheral
  ) {
  }

  fileprivate let subject = PublishRelay<CentralManager.Event>()

  @MainActor
  required init(_ manager: CentralManager) {
    super.init(parentObject: manager, delegateProxy: CombineCentralManagerDelegateProxy.self)
  }

  static func currentDelegate(for object: CentralManager) -> (any CentralManagerDelegate)? {
    object.delegate
  }

  static func setCurrentDelegate(_ delegate: (any CentralManagerDelegate)?, to object: CentralManager) {
    object.delegate = delegate
  }

  @MainActor
  static func registerKnownImplementations() {
    register { CombineCentralManagerDelegateProxy($0) }
  }

  deinit {
    subject.on(.completed)
  }

  nonisolated func centralManagerDidUpdateState(_ central: CentralManager) {
    subject.on(next: .stateUpdated(central.state))
  }

  nonisolated func centralManager(_ central: CentralManager, didConnect peripheral: Peripheral) {
    subject.on(next: .connected(peripheral))
  }

  nonisolated func centralManager(
    _ central: CentralManager,
    didDiscover peripheral: Peripheral,
    advertisementData: UncheckedSendable<[String: Any]>,
    rssi RSSI: NSNumber
  ) {
    subject.on(next: .discovered(peripheral, advertisementData, RSSI))
  }

  nonisolated func centralManager(
    _ central: CentralManager,
    didFailToConnect peripheral: Peripheral,
    error: (any Error)?
  ) {
    subject.on(next: .failToConnect(peripheral, error))
  }

  nonisolated func centralManager(
    _ central: CentralManager,
    didDisconnectPeripheral peripheral: Peripheral,
    error: (any Error)?
  ) {
    subject.on(next: .disconnected(peripheral, error))
  }

  nonisolated func centralManager(
    _ central: CentralManager,
    didDisconnectPeripheral peripheral: Peripheral,
    timestamp: CFAbsoluteTime,
    isReconnecting: Bool,
    error: (any Error)?
  ) {
    subject.on(next: .disconnectedReconnecting(peripheral, timestamp, isReconnecting, error))
  }

  nonisolated func centralManager(_ central: CentralManager, willRestoreState dict: UncheckedSendable<[String: Any]>) {
    subject.send(.restoreState(dict))
  }

  func centralManager(_ central: CentralManager, willRestoreStatePeripherals peripherals: [Peripheral]) {
    subject.send(.restoreStatePeripherals(peripherals))
  }
}

@MainActor
public extension Reactive where Base: CentralManager {
  var response: Observable<CentralManager.Event> {
    CombineCentralManagerDelegateProxy.proxy(for: base).subject.eraseToAnyPublisher()
  }

  var scanResults: Observable<CentralManager.Event> {
    response.filter {
      switch $0 {
      case .discovered: true
      default: false
      }
    }
    .eraseToAnyPublisher()
  }

  var connectState: Observable<CentralManager.Event> {
    response.filter {
      switch $0 {
      case .connected, .disconnected, .disconnectedReconnecting: true
      default: false
      }
    }
    .eraseToAnyPublisher()
  }

  var state: Observable<CBManagerState?> {
    response
      .filter {
        switch $0 {
        case .stateUpdated: true
        default: false
        }
      }
      .map {
        if case let .stateUpdated(state) = $0 {
          state
        } else {
          .none
        }
      }
      .eraseToAnyPublisher()
  }

  var isScanning: Observable<Bool> {
    base.cbCentralManager
      .publisher(for: \.isScanning, options: [.old, .new])
      .eraseToAnyPublisher()
  }

  private struct Startup {
    var restoreReceived = false
    var poweredOnReceived = false
  }
}
