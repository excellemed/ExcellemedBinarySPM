import Foundation

import enum Network.NWError
import class Network.NWProtocolWebSocket

public enum WebSocketEvent {
  case connected
  case disconnected(NWProtocolWebSocket.CloseCode, Data?)
  case viability(Bool)
  case error(NWError)
  case pong
  case data(Data)
  case text(String)
  case migrate(Result<any WebSocketConnection, NWError>)
}

extension WebSocket: @retroactive HasDelegate {
  public typealias Delegate = WebSocketConnectionDelegate
}

extension WebSocket: @retroactive CombineCompatible {}

@MainActor
class RxWebSocketDelegateProxy: DelegateProxy<WebSocket, WebSocketConnectionDelegate>, DelegateProxyType,
  WebSocketConnectionDelegate {
  func webSocketDidConnect(connection: any WebSocketConnection) {
    subject.on(next: .connected)
  }

  func webSocketDidDisconnect(
    connection: any WebSocketConnection,
    closeCode: NWProtocolWebSocket.CloseCode,
    reason: Data?,
  ) {
    subject.on(next: .disconnected(closeCode, reason))
  }

  func webSocketViabilityDidChange(connection: any WebSocketConnection, isViable: Bool) {
    subject.on(next: .viability(isViable))
  }

  func webSocketDidAttemptBetterPathMigration(result: Result<any WebSocketConnection, NWError>) {
    subject.on(next: .migrate(result))
  }

  func webSocketDidReceiveError(connection: any WebSocketConnection, error: NWError) {
    subject.on(next: .error(error))
  }

  func webSocketDidReceivePong(connection: any WebSocketConnection) {
    subject.on(next: .pong)
  }

  func webSocketDidReceiveMessage(connection: any WebSocketConnection, string: String) {
    subject.on(next: .text(string))
  }

  func webSocketDidReceiveMessage(connection: any WebSocketConnection, data: Data) {
    subject.on(next: .data(data))
  }

  fileprivate let subject = PublishRelay<WebSocketEvent>()

  required init(websocket: WebSocket) {
    super.init(parentObject: websocket, delegateProxy: RxWebSocketDelegateProxy.self)
  }

  @MainActor
  static func currentDelegate(for object: WebSocket) -> (any WebSocketConnectionDelegate)? {
    object.delegate
  }

  @MainActor
  static func setCurrentDelegate(_ delegate: (any WebSocketConnectionDelegate)?, to object: WebSocket) {
    object.delegate = delegate
  }

  static func registerKnownImplementations() {
    register { RxWebSocketDelegateProxy(websocket: $0) }
  }

  isolated deinit {
    subject.on(.completed)
  }
}

@MainActor
public extension Reactive where Base: WebSocket {
  var response: Observable<WebSocketEvent> {
    RxWebSocketDelegateProxy.proxy(for: base).subject.eraseToAnyPublisher()
  }

  var text: Observable<String> {
    response
      .filter {
        switch $0 {
        case .text: true
        default: false
        }
      }
      .map {
        switch $0 {
        case let .text(text): text
        default: ""
        }
      }
      .eraseToAnyPublisher()
  }
  
  var pong: Observable<String> {
    response
      .filter {
        switch $0 {
        case .pong: true
        default: false
        }
      }
      .map {
        switch $0 {
        case .pong: "pong"
        default: ""
        }
      }
      .eraseToAnyPublisher()
  }

  var connected: Observable<Bool> {
    response
      .filter {
        switch $0 {
        case .connected, .disconnected: true
        default: false
        }
      }
      .map {
        switch $0 {
        case .connected: true
        default: false
        }
      }
      .removeDuplicates()
      .eraseToAnyPublisher()
  }

  func write(data: Data) -> Observable<Void> {
    Deferred { [unowned base] in
      base.send(data: data)
      return Just(())
    }
    .eraseToAnyPublisher()
  }

  func write(str: String) -> Observable<Void> {
    Deferred { [unowned base] in
      base.send(string: str)
      return Just(())
    }
    .eraseToAnyPublisher()
  }
}
