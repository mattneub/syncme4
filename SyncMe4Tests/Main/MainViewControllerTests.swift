@testable import SyncMe4
import Testing
import AppKit
import WaitWhile

struct MainViewControllerTests {
    let subject = MainViewController()
    let processor = MockProcessor<MainAction, MainState, Void>()

    init() {
        subject.processor = processor
    }

    @Test("nibName: is correct")
    func nibName() {
        #expect(subject.nibName == "Main")
    }

    @Test("present: sets leftField and rightField object value")
    func present() async {
        subject.loadViewIfNeeded()
        let url1 = URL(string: "http://www.example1.com")!
        let url2 = URL(string: "http://www.example2.com")!
        var state = MainState()
        state.leftFolder = url1
        state.rightFolder = url2
        await subject.present(state)
        #expect(subject.leftField.objectValue as? URL == url1)
        #expect(subject.rightField.objectValue as? URL == url2)
    }

    @Test("textFieldChanged: sends left/right field changed depending on sender")
    func textFieldChanged() async {
        subject.loadViewIfNeeded()
        let url1 = URL(string: "http://www.example1.com")!
        let url2 = URL(string: "http://www.example2.com")!
        subject.leftField.objectValue = url1
        subject.rightField.objectValue = url2
        subject.textFieldChanged(subject.leftField!)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.leftFieldChanged(url1)])
        processor.thingsReceived = []
        subject.textFieldChanged(subject.rightField!)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.rightFieldChanged(url2)])
    }

    @Test("leftFieldChoose: sends left field choose with sender's window")
    func leftFieldChoose() async {
        let view = NSView()
        let window = makeWindow(view: view)
        subject.leftFieldChoose(view)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.leftFieldChoose(window)])
        closeWindows()
    }

    @Test("rightFieldChoose: sends right field choose with sender's window")
    func rightFieldChoose() async {
        let view = NSView()
        let window = makeWindow(view: view)
        subject.rightFieldChoose(view)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.rightFieldChoose(window)])
        closeWindows()
    }
}
