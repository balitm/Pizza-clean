import Foundation
import os

public nonisolated(unsafe) let DLog = DLogger()

public class DLogger {
    public enum LogLevel {
        case trace, debug, info, warn, error, fatal

        var prefix: String {
            switch self {
            case .trace:
                "🔍"
            case .debug:
                "⚙️"
            case .info:
                "ℹ️"
            case .warn:
                "⚠️"
            case .error:
                "🛑"
            case .fatal:
                "⛔"
            }
        }

        var osLevel: OSLogType {
            switch self {
            case .trace:
                .debug
            case .debug:
                .debug
            case .info:
                .info
            case .warn:
                .error
            case .error:
                .error
            case .fatal:
                .fault
            }
        }
    }

    private let _logger = Logger(subsystem: "MAVApp.DLog", category: "General")

    init() {}

    public func callAsFunction(l level: LogLevel = .info, _ string: @autoclosure () -> String, file: String = #file, line: Int = #line) {
#if DEBUG
        let text = string()
        consoleLog(level: level, "<\(file.lastPathComponent):\(line)> \(text)")
#endif
    }

    public func callAsFunction(l level: LogLevel = .info, file: String = #file, line: Int = #line, _ items: Any...) {
#if DEBUG
        let (f, s) = message(file: file, items: items)
        consoleLog(level: level, "<\(f):\(line)> \(s)")
#endif
    }

#if DEBUG
    private func consoleLog(level: LogLevel, _ message: String) {
        _logger.log(level: level.osLevel, "\(level.prefix) \(message)")
    }

    private func message(file: String, items: [Any]) -> (String, String) {
        var s = ""
        for item in items {
            s += String(describing: item)
        }
        let file = file.lastPathComponent
        return (file, s)
    }
#endif
}

private func _rfind<C: Collection>(domain: C, value: C.Element) -> C.Index? where C.Element: Equatable {
    for idx in domain.indices.reversed() {
        if domain[idx] == value {
            return idx
        }
    }
    return nil
}

extension String {
    var lastPathComponent: String {
        componentsSeparated(by: "/")
    }

    var withoutExtension: String {
        components(separatedBy: ".").first ?? self
    }

    func componentsSeparated(by separator: String.Element) -> String {
        if let idx = _rfind(domain: self, value: separator) {
            return String(self[index(after: idx)...])
        }
        return self
    }
}
