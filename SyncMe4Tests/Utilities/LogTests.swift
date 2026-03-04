import Testing
@testable import SyncMe4

struct LogTests {
    @Test("append: appends text plus two linefeeds")
    func append() {
        let subject = Log()
        subject.log = ""
        subject.append("test")
        #expect(subject.log == "test\n\n")
        subject.append("test2")
        #expect(subject.log == "test\n\ntest2\n\n")
    }
}
