@testable import SyncMe4
import Foundation

@Observable
final class MockLog: LogType {
    var methodsCalled = [String]()
    var log: String = ""
    var text: String?
    func append(_ text: String) {
        methodsCalled.append(#function)
        self.text = text
    }
}
