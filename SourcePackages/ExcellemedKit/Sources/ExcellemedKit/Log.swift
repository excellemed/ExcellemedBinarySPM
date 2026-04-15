import Foundation
import MetricKit
import ToolKit

private final nonisolated class LogFileWriter: Sendable {
  static let shared = LogFileWriter()

  private let logDirectory: URL
  private let maxDays = 7
  private let state: Mutex<State>

  private struct State {
    var currentDate = ""
    var fileHandle: FileHandle?
  }

  private init() {
    let documentsPath = PathProvider.getApplicationDocumentsDirectory() ?? NSTemporaryDirectory()
    self.logDirectory = URL(fileURLWithPath: documentsPath).appendingPathComponent("Logs")
    self.state = Mutex(State())
    try? FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: true)
    cleanOldLogs()
  }

  func write(level: String, category: String, message: String, fileID: String, line: Int) {
    let now = Date()
    let dateString = now.ex.stringify("yyyy-MM-dd")
    let timestamp = now.ex.stringify("HH:mm:ss.SSS")
    let logLine = "\(timestamp) [\(level)] [\(category)] [\(fileID):\(line)] \(message)\n"

    #if DEBUG
    print(logLine, terminator: "")
    #endif

    state.withLock { state in
      if dateString != state.currentDate {
        state.fileHandle?.closeFile()
        state.fileHandle = nil
        state.currentDate = dateString
      }

      if state.fileHandle == nil {
        let fileURL = logDirectory.appendingPathComponent("\(dateString).log")
        if !FileManager.default.fileExists(atPath: fileURL.path) {
          FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        }
        state.fileHandle = try? FileHandle(forWritingTo: fileURL)
        state.fileHandle?.seekToEndOfFile()
      }

      state.fileHandle?.write(Data(logLine.utf8))
    }
  }

  private func cleanOldLogs() {
    let cutoff = Calendar.current.date(byAdding: .day, value: -maxDays, to: Date()) ?? Date()
    guard let files = try? FileManager.default.contentsOfDirectory(at: logDirectory, includingPropertiesForKeys: nil)
    else { return }

    for file in files where file.pathExtension == "log" {
      let name = file.deletingPathExtension().lastPathComponent
      if let fileDate = name.ex.time(dateFormat: "yyyy-MM-dd"), fileDate < cutoff {
        try? FileManager.default.removeItem(at: file)
      }
    }
  }
}

public nonisolated struct AppLogger: Sendable {
  private let category: String

  public init(subsystem: String, category: String) {
    self.category = category
  }

  public func debug(_ message: String, fileID: String = #fileID, line: Int = #line) {
    #if DEBUG
    LogFileWriter.shared.write(level: "DEBUG", category: category, message: message, fileID: fileID, line: line)
    #endif
  }

  public func info(_ message: String, fileID: String = #fileID, line: Int = #line) {
    LogFileWriter.shared.write(level: "INFO", category: category, message: message, fileID: fileID, line: line)
  }

  public func warning(_ message: String, fileID: String = #fileID, line: Int = #line) {
    LogFileWriter.shared.write(level: "WARN", category: category, message: message, fileID: fileID, line: line)
  }

  public func error(_ message: String, fileID: String = #fileID, line: Int = #line) {
    LogFileWriter.shared.write(level: "ERROR", category: category, message: message, fileID: fileID, line: line)
  }

  public func fault(_ message: String, fileID: String = #fileID, line: Int = #line) {
    LogFileWriter.shared.write(level: "FAULT", category: category, message: message, fileID: fileID, line: line)
  }
}

public nonisolated enum Log: Sendable {
  private static let subsystem = Bundle.main.bundleIdentifier ?? "com.cgm"

  public static let net = AppLogger(subsystem: subsystem, category: "Net")
  public static let ws = AppLogger(subsystem: subsystem, category: "WebSocket")
  public static let ble = AppLogger(subsystem: subsystem, category: "BLE")
  public static let auth = AppLogger(subsystem: subsystem, category: "Auth")
  public static let general = AppLogger(subsystem: subsystem, category: "General")
  public static let crash = AppLogger(subsystem: subsystem, category: "Crash")
}

@MainActor
public final class CrashSubscriber: NSObject, MXMetricManagerSubscriber {
  public static let shared = CrashSubscriber()

  public func start() {
    MXMetricManager.shared.add(self)
  }

  public nonisolated func didReceive(_ payloads: [MXDiagnosticPayload]) {
    for payload in payloads {
      if let crashDiagnostics = payload.crashDiagnostics {
        for crash in crashDiagnostics {
          Log.crash.fault("Crash: \(crash.applicationVersion) signal \(crash.signal ?? 0)")
          let callStack = crash.callStackTree.jsonRepresentation()
          Log.crash.fault("CallStack: \(String(bytes: callStack, encoding: .utf8) ?? "")")
        }
      }
      if let hangDiagnostics = payload.hangDiagnostics {
        for hang in hangDiagnostics {
          Log.crash.error("Hang: \(hang.hangDuration) \(hang.applicationVersion)")
          let callStack = hang.callStackTree.jsonRepresentation()
          Log.crash.error("HangStack: \(String(bytes: callStack, encoding: .utf8) ?? "")")
        }
      }
    }
  }
}
