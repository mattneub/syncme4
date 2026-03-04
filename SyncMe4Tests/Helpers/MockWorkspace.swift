@testable import SyncMe4
import Foundation

final class MockWorkspace: WorkspaceType {
    var methodsCalled = [String]()
    var url: URL?

    func open(_ url: URL) -> Bool {
        methodsCalled.append(#function)
        self.url = url
        return true
    }

}
