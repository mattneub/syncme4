import Testing
@testable import SyncMe4
import AppKit
import WaitWhile

struct LogProcessorTests {
    let subject = LogProcessor()
    let presenter = MockReceiverPresenter<Void, LogState>()
    let log = MockLog()

    init() {
        subject.presenter = presenter
        services.log = log
    }

    @Test("receive initialData: starts observing log; if log emits, sets state, presents")
    func initialData() async {
        log.log = ""
        #expect(subject.cancellableTask == nil)
        await subject.receive(.initialData)
        await #while(subject.cancellableTask == nil)
        await #while(presenter.statesPresented.count == 0)
        #expect(presenter.statesPresented.count == 1)
        #expect(presenter.statesPresented[0].text == "No errors.") // text for empty string
        log.log = "howdy"
        await #while(presenter.statesPresented.count == 1)
        #expect(presenter.statesPresented.count == 2)
        #expect(presenter.statesPresented[1].text == "howdy") // text matches log
        subject.cancellableTask?.cancel()
        log.log = "done"
    }
}
