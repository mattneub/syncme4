@testable import SyncMe4
import Testing

struct StringTests {
    @Test("urlWrap inserts no-break space after slash")
    func urlWrap() {
        let result = "a/b/c/".urlWrap
        #expect(result == "a/\u{200B}b/\u{200B}c/\u{200B}")
    }

    @Test("escapedString: translates line endings into backslashed characters")
    func escapedString() {
        let result = "a\nb\nc\r".escapedString
        let expectedResult = "a\\nb\\nc\\r"
        #expect(result == expectedResult)
    }

    @Test("unescapedString: translates backslashed characters into line endings")
    func unescapedString() {
        let result = "a\\nb\\nc\\r".unescapedString
        let expectedResult = "a\nb\nc\r"
        #expect(result == expectedResult)
    }
}
