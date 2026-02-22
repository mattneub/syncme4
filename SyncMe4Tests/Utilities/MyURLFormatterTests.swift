@testable import SyncMe4
import Testing
import AppKit

private struct MyURLFormatterTests {
    let subject = MyURLFormatter()

    @Test("stringForObject: creates path string of URL, or empty string if not file URL")
    func stringForObject() {
        #expect(subject.string(for: "howdy") == "")
        #expect(subject.string(for: URL(string: "http://www.example.com")!) == "")
        #expect(subject.string(for: URL(string: "file:///testing%20this")) == "/testing this")
    }

    @Test("getObjectValue: turns path string into file URL")
    func getObjectValue() throws {
        var result: AnyObject? = URL(string: "http://www.example.com")! as NSURL
        let ok = subject.getObjectValue(&result, for: "/testing", errorDescription: nil)
        #expect(ok == true)
        let realResult = try #require(result! as? NSURL)
        #expect((realResult as URL) == URL(string: "file:///testing/")!)
    }

    @Test("getObjectValue: turns empty string into nil")
    func getObjectValueEmptyString() throws {
        var result: AnyObject? = URL(string: "http://www.example.com")! as NSURL
        let ok = subject.getObjectValue(&result, for: "", errorDescription: nil)
        #expect(ok == true)
        #expect(result == nil)
    }
}
