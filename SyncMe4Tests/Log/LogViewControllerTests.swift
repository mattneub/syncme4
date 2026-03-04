import Testing
@testable import SyncMe4
import AppKit
import WaitWhile

struct LogViewControllerTests {
    let subject = LogViewController()
    let processor = MockReceiver<LogAction>()

    init() {
        subject.processor = processor
    }

    @Test("text view: is correctly initialized")
    func textView() {
        subject.textView = NSTextView()
        #expect(subject.textView?.string == "No errors.")
    }

    @Test("viewDidLoad: sends initialData")
    func viewDidLoad() async {
        subject.viewDidLoad()
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.initialData])
    }

    @Test("present: sets text view string, calls scrollToEnd")
    func present() async {
        let textView = MockTextView()
        subject.textView = textView
        await subject.present(LogState(text: "howdy"))
        #expect(textView.string == "howdy")
        #expect(textView.methodsCalled == ["scrollToEndOfDocument(_:)"])
    }

}

private final class MockTextView: NSTextView {
    var methodsCalled = [String]()

    override func scrollToEndOfDocument(_ sender: Any?) {
        methodsCalled.append(#function)
    }
}
