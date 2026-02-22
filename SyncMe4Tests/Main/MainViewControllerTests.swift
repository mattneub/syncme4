@testable import SyncMe4
import Testing
import AppKit

struct MainViewControllerTests {
    let subject = MainViewController()

    @Test("nibName: is correct")
    func nibName() {
        #expect(subject.nibName == "Main")
    }

}
