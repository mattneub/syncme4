@testable import SyncMe4
import Testing

struct ReasonTests {
    @Test("imageName is correct based on reason")
    func image() {
        var why = Reason.absentLeft
        #expect(why.imageName == "leftarrowgreen")
        why = Reason.absentRight
        #expect(why.imageName == "rightarrowgreen")
        why = Reason.olderLeft
        #expect(why.imageName == "leftarrowred")
        why = Reason.olderRight
        #expect(why.imageName == "rightarrowred")
    }
}
