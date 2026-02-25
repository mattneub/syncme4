@testable import SyncMe4
import Testing

struct StringTests {
    @Test("urlWrap inserts no-break space after slash")
    func urlWrap() {
        let result = "a/b/c/".urlWrap
        #expect(result == "a/\u{200B}b/\u{200B}c/\u{200B}")
    }
}
