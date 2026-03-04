import Foundation

protocol LogType {
    var log: String { get }
    func append(_ text: String)
}

@Observable
final class Log: LogType {
    var log: String = ""

    func append(_ text: String) {
        log += "\(text)\n\n"
    }
}
